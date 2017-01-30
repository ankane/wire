module Wire
  module Subscriber
    extend ActiveSupport::Concern

    class_methods do
      # TODO don't pollute
      attr_reader :wire_consumer

      def subscribe(*args, as: nil)
        permitted_attributes = args.map(&:to_s)
        model = self

        @wire_consumer = Class.new(Wire::Consumer)
        @wire_consumer.send :define_singleton_method, :name do
          "Wire::AutoSubscriber::#{model.name}"
        end

        @wire_consumer.send :define_method, :perform do |payload|
          record = model.find_by(id: payload["id"])
          if payload["destroyed"]
            record.destroy if record
          else
            unless record
              record = model.new
              record.id = payload["id"]
            end
            record.assign_attributes(payload["attributes"].slice(*permitted_attributes))
            record.save!
          end
        end
        topic = as ? as.to_s : model.model_name.name
        @wire_consumer.topic "#{topic.underscore}_update"

        Wire.consumers << @wire_consumer
      end
    end
  end
end

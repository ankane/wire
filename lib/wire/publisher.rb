module Wire
  module Publisher
    extend ActiveSupport::Concern

    class_methods do
      def publish(*args)
        unless respond_to?(:publish_attributes)
          include Wire::PublisherMethods
          self.publish_attributes = []
        end
        self.publish_attributes.concat(args.map(&:to_s))
      end
    end
  end
end

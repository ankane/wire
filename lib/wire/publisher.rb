module Wire
  module Publisher
    extend ActiveSupport::Concern

    class_methods do
      def publish(*args)
        include Wire::PublisherMethods
        self.publish_attributes = args.map(&:to_s)
      end
    end
  end
end

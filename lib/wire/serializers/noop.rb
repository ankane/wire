module Wire
  module Serializers
    class Noop
      def serialize(data)
        raise Wire::Error, "Must pass a string" unless data.is_a?(String)
        data
      end

      def deserialize(data)
        data
      end
    end
  end
end

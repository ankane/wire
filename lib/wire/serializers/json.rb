require "json"

module Wire
  module Serializers
    class JSON
      def serialize(data)
        ::JSON.generate(data)
      end

      def deserialize(data)
        ::JSON.parse(data)
      end
    end
  end
end

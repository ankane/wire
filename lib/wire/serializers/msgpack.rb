module Wire
  module Serializers
    class Msgpack
      def serialize(data)
        ::MessagePack.pack(data)
      end

      def deserialize(data)
        ::MessagePack.unpack(data)
      end
    end
  end
end

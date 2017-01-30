module Wire
  class Consumer
    attr_reader :metadata

    def initialize(metadata: nil)
      @metadata = metadata
    end

    def self.inherited(descendant)
      Wire.consumers << descendant
    end

    def self.topic(topic = nil)
      @topic = topic if topic
      @topic
    end

    def self.serializer(serializer = nil)
      @serializer = serializer if serializer
      @serializer
    end

    def self.perform_now(payload)
      serializer = Wire.find_serializer(self.serializer)
      new.perform(serializer.deserialize(serializer.serialize(payload)))
    end

    def self.consume_once
      ConsumerGroup.new.run(consumers: [self], consume_once: true)
    end
  end
end

require "errbase"

module Wire
  class ConsumerGroup
    def run(consumers: nil, consume_once: false, clear: false)
      Rails.application.eager_load! if defined?(Rails)

      consumers_by_topic = {}
      (consumers || Wire.consumers).uniq.each do |consumer|
        topic = consumer.topic
        if topic
          (consumers_by_topic[topic.to_s] ||= []) << consumer
        else
          logger.warn "No topic for #{consumer.name}"
        end
      end
      raise Wire::Error, "No consumers" if consumers_by_topic.empty?

      logger.info "Starting consumers: #{consumers_by_topic.values.flatten.map(&:name).sort.join(", ")}"

      @consumer =
        Wire.client.consumer(
          group_id: Wire.app,
          offset_commit_threshold: 1,
          session_timeout: 10
        )

      consumers_by_topic.each do |topic, _|
        @consumer.subscribe(topic)
      end

      @consumer.each_message(max_wait_time: 1) do |message|
        metadata = {
          key: message.key,
          partition: message.partition,
          offset: message.offset,
          topic: message.topic,
          value: message.value
        }

        consumers_by_topic[message.topic].each do |consumer|
          start_time = Time.now
          begin
            consumer.new(metadata: metadata).perform(Wire.find_serializer(consumer.serializer).deserialize(message.value)) unless clear
            duration = (Time.now - start_time) * 1000
            logger.info "Performed #{consumer.name} from (#{message.topic}) in #{duration.round}ms"
          rescue => e
            duration = (Time.now - start_time) * 1000
            logger.error "Error: #{e.class.name}: #{e.message} in #{consumer.name} from (#{message.topic}) in #{duration.round}ms"
            Errbase.report(e)
          end
        end
        @consumer.stop if consume_once
      end
    end

    def stop
      warn "Shutting down consumers"
      @consumer.stop if @consumer
      @consumer = nil
    end

    def logger
      Wire.logger
    end
  end
end

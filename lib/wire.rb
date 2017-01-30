require "kafka"
require "logger"
require "wire/consumer"
require "wire/consumer_group"
require "wire/publisher"
require "wire/publisher_methods"
require "wire/railtie" if defined?(Rails)
require "wire/serializers/json"
require "wire/serializers/msgpack"
require "wire/serializers/noop"
require "wire/subscriber"
require "wire/version"

module Wire
  class Error < StandardError; end

  class << self
    attr_accessor :consumers, :default_serializer, :logger
    attr_writer :app, :client_id, :client
  end
  self.consumers = []
  self.default_serializer = :json
  self.logger = Logger.new(STDOUT)

  def self.client
    @client ||= Kafka.new(
      seed_brokers: ENV["KAFKA_URL"] || "kafka://127.0.0.1:9092",
      connect_timeout: 1,
      socket_timeout: 1
    )
  end

  def self.producer
    @producer ||= begin
      producer = client.async_producer(ack_timeout: 1)
      at_exit { producer.shutdown }
      producer
    end
  end

  def self.publish(topic, payload, partition: nil, partition_key: nil, key: nil, serializer: nil)
    client.deliver_message(find_serializer(serializer).serialize(payload), {
      topic: topic.to_s,
      partition: partition ? partition.to_i : partition,
      partition_key: partition_key ? partition_key.to_s : partition_key,
      key: key ? key.to_s : key
    })
    # TODO option to use async producer
    # producer.produce(payload.to_json)
    logger.info "Published #{payload.inspect} to (#{topic})"
    true
  end

  def self.register_serializer(key, klass, default: false)
    @serializers ||= {}
    @serializers[key] = klass.new
    self.default_serializer = key if default
    true
  end

  def self.app
    @app ||= ENV["WIRE_APP"] || "wire"
  end

  # private
  def self.find_serializer(key)
    s = key || default_serializer
    serializer = @serializers[s]
    raise Wire::Error, "Unknown serializer: #{s}" unless s
    serializer
  end
end

Wire.register_serializer(:json, Wire::Serializers::JSON)
Wire.register_serializer(:msgpack, Wire::Serializers::Msgpack)
Wire.register_serializer(:noop, Wire::Serializers::Noop)

if defined?(ActiveSupport)
  ActiveSupport.on_load(:active_record) do
    include Wire::Publisher
    include Wire::Subscriber
  end
  Wire.logger = ActiveSupport::Logger.new(STDOUT)
end

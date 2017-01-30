# Wire

:fire: A pub-sub framework built on Kafka

**Proof-of-concept**, so you probably shouldn’t use it in production

## Getting Started

First, [install Kafka](https://kafka.apache.org/quickstart). With Homebrew, use:

```sh
brew install kafka
brew services start zookeeper
brew services start kafka
```

Add this line to your application’s Gemfile:

```ruby
gem "wire", github: "ankane/wire"
```

Publish a message with:

```ruby
Wire.publish(:visit, {name: "McNulty"})
```

Create a new consumer with:

```sh
rails generate wire:consumer Welcome
```

It’ll be placed in `app/consumers`. Update it to:

```ruby
class WelcomeConsumer < Wire::Consumer
  topic :visit

  def perform(message)
    puts "Hi #{message["name"]}"
  end
end
```

Run consumers with:

```ruby
bundle exec wire
```

## Model Updates

Publish model updates from one app

```ruby
class User < ActiveRecord::Base
  publish :name, :email
end
```

And subscribe in another app (start consumers as normal)

```ruby
class User < ActiveRecord::Base
  subscribe :name, :email
end
```

To sync all records, use:

```ruby
User.find_each { |user| user.sync }
```

## More Features

To make development easier, you can run consumers immediately with:

```ruby
WelcomeConsumer.perform_now(message)
```

To consume a single message, use:

```ruby
WelcomeConsumer.consume_once
```

## Metadata

Use the `metadata` method to access info like partition, offset, key, and raw value.

```ruby
class WelcomeConsumer < Wire::Consumer
  def perform(message)
    metadata[:partition]
    metadata[:offset]
    metadata[:key]
    metadata[:value]
  end
end
```

## Serialization

By default, Wire uses JSON for serialization.

To disable serialization, use:

```ruby
Wire.default_serializer = :noop
```

For MessagePack, add [msgpack](https://github.com/msgpack/msgpack-ruby) to your Gemfile and use:

```ruby
Wire.default_serializer = :msgpack
```

Or create a custom serializer

```ruby
class CustomSerializer
  def serialize(data)
    data + "!!!"
  end

  def deserialize(data)
    data.chomp("!!!")
  end
end

Wire.register_serializer(:custom, CustomSerializer, default: true)
```

You can also specify a serializer when publishing

```ruby
Wire.publish(topic, message, serializer: :msgpack)
```

Or consuming

```ruby
class MessageConsumer < Wire::Consumer
  serializer :msgpack
end
```

## TODO

- Multi-threaded consumers
- Auto-reload consumers
- Connection pool for publish
- Hooks for instrumentation
- Ability to disable consumers
- Retries

## Credits

Thanks to [Promiscuous](https://github.com/promiscuous-io/promiscuous) for designing a great interface for model updates.

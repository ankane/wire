require "bundler/setup"
require "active_support"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"
require "active_record"
require "msgpack"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: "/tmp/wire.sqlite"

ActiveRecord::Migration.create_table :users, force: :cascade do |t|
  t.string :name
  t.timestamp :joined_at
end

ActiveRecord::Migration.create_table :people, force: :cascade do |t|
  t.string :name
  t.timestamp :joined_at
end

class User < ActiveRecord::Base
  publish :name, :joined_at
end

class Person < ActiveRecord::Base
  subscribe :name, :joined_at, as: :user
end

class TestConsumer < Wire::Consumer
  topic :test

  def perform(payload)
    $payload = payload
  end
end

class MsgpackConsumer < Wire::Consumer
  topic :test2
  serializer :msgpack

  def perform(payload)
    $payload = payload
  end
end

# clear queue
server = Wire::ConsumerGroup.new
t = Thread.new { server.run(clear: true) }
sleep(2)
server.stop
t.join

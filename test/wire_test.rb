require "test_helper"

class WireTest < Minitest::Test
  def test_consumer
    now = Time.now.to_i
    Wire.publish(:test, now)
    TestConsumer.consume_once
    assert_equal now, $payload
  end

  def test_perform_now
    TestConsumer.perform_now("hello")
    assert_equal "hello", $payload
  end

  def test_perform_now_serialize
    payload = {hello: "world"}
    TestConsumer.perform_now(payload)
    assert_equal ({"hello" => "world"}), $payload
  end

  def test_model
    User.delete_all
    Person.delete_all

    User.create!(name: "Kona", joined_at: Time.now)
    assert !Person.exists?
    Person.wire_consumer.consume_once
    assert_equal 1, Person.count
    assert_same_elements User.order(:id).pluck(:id, :name, :joined_at), Person.order(:id).pluck(:id, :name, :joined_at)
    User.destroy_all
    assert_equal 1, Person.count
    Person.wire_consumer.consume_once
    assert !Person.exists?
  end

  def test_serializer
    now = Time.now.to_i
    Wire.publish(:test2, now, serializer: :msgpack)
    MsgpackConsumer.consume_once
    assert_equal now, $payload
  end

  def test_sync
    User.delete_all
    Person.delete_all

    User.create!(name: "Kona")
    Person.wire_consumer.consume_once

    Person.first.update(name: "Ginger")
    assert_equal "Ginger", Person.first.name

    User.find_each(&:sync)
    Person.wire_consumer.consume_once
    assert_equal "Kona", Person.first.name
  end

  # TODO better version
  def assert_same_elements(a1, a2)
    assert_equal a1.map(&:to_s), a2.map(&:to_s)
  end
end

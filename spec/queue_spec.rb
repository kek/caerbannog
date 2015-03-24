require 'spec_helper'

describe Caerbannog::Queue do
  describe '.push' do
    it 'must be configured with a message_class' do
      expect { Caerbannog::Queue.push('rabbit', {}) }.to raise_error(Caerbannog::ConfigurationError)
    end

    it 'creates a Message' do
      message_class = stub
      message_class.expects(:create!).with(name: 'name', payload: '{"a":"1"}')
      Caerbannog.configure { |config| config.message_class = message_class }
      Caerbannog::Queue.push('name', { 'a' => '1' })
    end
  end

  describe '.rabbitmq' do
    it 'must be configured with read and write URLs' do
      expect { Caerbannog::Queue.rabbitmq(nil) {} }.to raise_error(Caerbannog::ConfigurationError)
    end

    it 'yields the exchange and the channel' do
      rabbit_url = 'http://example.com/rabbits'
      exchange, channel = stub_bunny(rabbit_url)
      checker = mock('checker')

      checker.expects(:has_yielded).with(exchange, channel)

      Caerbannog::Queue.rabbitmq rabbit_url do |ex, ch|
        checker.has_yielded(ex, ch)
      end
    end
  end

  describe '.subscribe' do
    it 'subscribes to a queue' do
      rabbit_read_url = 'http://example.com/rx'
      exchange, channel = stub_bunny(rabbit_read_url)
      queue = mock('queue')
      checker = mock('checker')
      yielded_params1 = [stub, stub, 'payload1']
      yielded_params2 = [stub, stub, 'payload2']
      block = proc { |a,b,c| checker.has_yielded a,b,c }

      channel.expects(:queue).with('queue_name').returns queue
      queue.expects(:bind).with(exchange, routing_key: 'issue_published')
      queue.expects(:bind).with(exchange, routing_key: 'issue_unpublished')
      queue.expects(:subscribe).with({ block: true }).multiple_yields(yielded_params1, yielded_params2)
      checker.expects(:has_yielded).with(*yielded_params1)
      checker.expects(:has_yielded).with(*yielded_params2)

      Caerbannog.configure { |config| config.rabbit_read_url = rabbit_read_url }
      Caerbannog::Queue.subscribe('queue_name', 'issue_published', 'issue_unpublished', &block)
    end
  end

  describe '.publish' do
    it 'publishes a stream of messages to the exchange' do
      rabbit_write_url = 'http://example.com/tx'
      exchange, _ = stub_bunny(rabbit_write_url)
      expected_name = 'something'
      expected_payload = '{"a":"1"}'
      message = mock('message', name: expected_name, payload: expected_payload)
      messages = [message]

      exchange.expects(:publish).with(expected_payload, routing_key: expected_name, persistent: true)
      message.expects(:destroy)

      Caerbannog.configure { |config| config.rabbit_write_url = rabbit_write_url }
      Caerbannog::Queue.publish(messages)
    end
  end
end

def stub_bunny(redis_url)
  exchange = mock('exchange')
  channel = mock('channel')
  conn = mock('conn')
  conn.expects(:create_channel).returns(channel)
  channel.expects(:direct).returns(exchange)
  Bunny.expects(:run).with(redis_url).yields(conn)

  return exchange, channel
end

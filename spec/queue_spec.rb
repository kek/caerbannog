require 'spec_helper'

describe Caerbannog::Queue do
  describe '.push' do
    it 'creates a Message' do
      message_class = stub
      message_class.expects(:create!).with(:name => 'name', :payload => '{"a":"1"}')
      Caerbannog::Queue.message_class = message_class
      Caerbannog::Queue.push('name', { 'a' => '1' })
    end
  end

  describe '.rabbitmq' do
    it 'yields the exchange and the channel' do
      exchange, channel = stub_bunny
      checker = mock('checker')

      checker.expects(:has_yielded).with(exchange, channel)

      Caerbannog::Queue.rabbitmq do |ex, ch|
        checker.has_yielded(ex, ch)
      end
    end
  end

  describe '.subscribe' do
    it 'subscribes to a queue' do
      exchange, channel = stub_bunny
      queue = mock('queue')
      checker = mock('checker')
      yielded_params1 = [stub, stub, 'payload1']
      yielded_params2 = [stub, stub, 'payload2']
      block = proc { |a,b,c| checker.has_yielded a,b,c }

      channel.expects(:queue).with('queue_name').returns queue
      queue.expects(:bind).with(exchange, :routing_key => 'issue_published')
      queue.expects(:bind).with(exchange, :routing_key => 'issue_unpublished')
      queue.expects(:subscribe).with({ :block => true }).multiple_yields(yielded_params1, yielded_params2)
      checker.expects(:has_yielded).with(*yielded_params1)
      checker.expects(:has_yielded).with(*yielded_params2)

      Caerbannog::Queue.subscribe('queue_name', 'issue_published', 'issue_unpublished', &block)
    end
  end

  describe '.publish' do
    it 'publishes a stream of messages to the exchange' do
      exchange, _ = stub_bunny
      expected_name = 'something'
      expected_payload = '{"a":"1"}'
      message = mock('message', :name => expected_name, :payload => expected_payload)
      messages = [message]

      exchange.expects(:publish).with(expected_payload, :routing_key => expected_name, :persistent => true)
      message.expects(:destroy)

      Caerbannog::Queue.publish(messages)
    end
  end
end

def stub_bunny
  exchange = mock('exchange')
  channel = mock('channel')
  conn = mock('conn')
  conn.expects(:create_channel).returns(channel)
  channel.expects(:direct).returns(exchange)
  Bunny.expects(:run).yields(conn)

  return exchange, channel
end

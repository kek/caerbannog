module Caerbannog
  class Queue
    def self.message_class=(message_class)
      @message_class = message_class
    end

    def self.push(name, payload)
      @message_class.create!(:name => name, :payload => JSON.generate(payload))
    end

    def self.rabbitmq
      Bunny.run ENV['RABBIT_URL'] do |conn|
        ch = conn.create_channel
        exchange = ch.direct('events', :durable => true)
        yield exchange, ch
      end
    end

    def self.subscribe(queue_name, *routing_keys, &block)
      rabbitmq do |exchange, channel|
        queue = channel.queue(queue_name)
        routing_keys.each { |routing_key| queue.bind(exchange, :routing_key => routing_key) }
        queue.subscribe(:block => true, &block)
      end
    end

    def self.publish(messages = MessagePoller.new(@message_class))
      rabbitmq do |exchange|
        messages.each do |message|
          exchange.publish(message.payload, :routing_key => message.name, :persistent => true)
          message.destroy
        end
      end
    end
  end
end

module Caerbannog
  class Queue
    def self.push(name, payload)
      raise ConfigurationError.new("Must configure #{self.name} with message_class") unless Caerbannog.message_class

      Caerbannog.message_class.create!(name: name, payload: JSON.generate(payload))
    end

    def self.rabbitmq(rabbit_url)
      raise ConfigurationError.new("Must configure #{self.name} with rabbit_read_url and/or rabbit_write_url") unless rabbit_url

      Bunny.run rabbit_url do |conn|
        ch = conn.create_channel
        exchange = ch.direct('events', durable: true)
        yield exchange, ch
      end
    end

    def self.subscribe(queue_name, *routing_keys, &block)
      rabbitmq Caerbannog.rabbit_read_url do |exchange, channel|
        queue = channel.queue(queue_name)
        routing_keys.each { |routing_key| queue.bind(exchange, routing_key: routing_key) }
        queue.subscribe(block: true, &block)
      end
    end

    def self.publish(messages = MessagePoller.new(@message_class))
      rabbitmq Caerbannog.rabbit_write_url do |exchange|
        messages.each do |message|
          exchange.publish(message.payload, routing_key: message.name, persistent: true)
          message.destroy
        end
      end
    end
  end
end

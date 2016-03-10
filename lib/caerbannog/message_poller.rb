module Caerbannog
  class MessagePoller
    def initialize(message_class, wait_time = 5, iterations = Float::INFINITY)
      @message_class = message_class
      @wait_time = wait_time
      @iterations = iterations
    end

    def each &block
      (1..iterations).each do
        new_messages = fetch_new_messages
        if new_messages.empty?
          sleep wait_time
        else
          new_messages.each(&block)
        end
      end
    end

    private

    attr_reader :wait_time, :iterations, :message_class

    def fetch_new_messages
      message_class.all
    end
  end
end

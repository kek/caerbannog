require 'spec_helper'

describe Caerbannog::MessagePoller do
  describe '#each' do
    it 'iterates over Message.all and waits for new results in Message.all' do
      single_message = stub
      one_of_two_messages = stub
      another_of_two_messages = stub
      message_history = sequence('message_history')
      message_class = stub
      message_class.expects(:all).returns([]).in_sequence(message_history)
      message_class.expects(:all).returns([single_message]).in_sequence(message_history)
      message_class.expects(:all).returns([one_of_two_messages, another_of_two_messages]).in_sequence(message_history)

      checker = mock('checker')
      checker.expects(:has_yielded).with(single_message).once
      checker.expects(:has_yielded).with(one_of_two_messages).once
      checker.expects(:has_yielded).with(another_of_two_messages).once

      message_poller = Caerbannog::MessagePoller.new(message_class, :wait_time => 0, :iterations => 3)
      message_poller.each do |message|
        checker.has_yielded message
      end
    end
  end
end

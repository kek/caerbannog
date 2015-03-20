Caerbannog::Queue.configure do |config|
  config.message_class = CaerbannogMessage
  config.rabbit_read_url = ENV['RABBIT_URL']
  config.rabbit_write_url = ENV['RABBIT_URL']
end

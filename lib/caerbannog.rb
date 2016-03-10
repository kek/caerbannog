require 'bundler/setup'
require 'bunny'
require 'json'

require_relative 'caerbannog/version'
require_relative 'caerbannog/message_poller'
require_relative 'caerbannog/queue'

module Caerbannog
  class ConfigurationError < StandardError; end

  class << self
    attr_accessor :message_class, :rabbit_read_url, :rabbit_write_url

    def configure
      yield self
    end
  end
end

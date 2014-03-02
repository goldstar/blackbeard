require "blackbeard/configuration"
require "blackbeard/pirate"

module Blackbeard
  class << self

    def configure!
      @config = Configuration.new
      yield config
    end

    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
    end

    def pirate
      yield(config) if block_given?
      Blackbeard::Pirate.new
    end
  end
end

Blackbeard.pirate {}

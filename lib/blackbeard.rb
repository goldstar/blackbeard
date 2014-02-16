require "blackbeard/configuration"
require "blackbeard/pirate"

module Blackbeard
  extend self
  attr_accessor :config

  def self.pirate
    @config ||= Configuration.new
    yield(config)
    Blackbeard::Pirate.new
  end

end

Blackbeard.pirate {}

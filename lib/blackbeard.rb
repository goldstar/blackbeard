require "blackbeard/configuration"
require "blackbeard/pirate"

module Blackbeard
  extend self
  attr_accessor :config

  def tz
    config.tz
  end

  def db
    config.db
  end

  def guest_method
    config.guest_method
  end

  def self.pirate
    @config ||= Configuration.new
    yield(config)
    Blackbeard::Pirate.new
  end

end

Blackbeard.pirate {}

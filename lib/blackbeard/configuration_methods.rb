module Blackbeard
  module ConfigurationMethods
    def self.included(base)
      base.extend(self)
    end

    def config
      Blackbeard.config
    end

    def db
      config.db
    end

    def tz
      config.tz
    end

    def guest_method
      config.guest_method
    end

  end
end

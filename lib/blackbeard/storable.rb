module Blackbeard
  class Storable
    def db
      self.class.db
    end

    def self.db
      Blackbeard.db
    end

    def tz
      self.class.tz
    end

    def self.tz
      Blackbeard.tz
    end
  end
end

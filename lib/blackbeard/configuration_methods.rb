module Blackbeard
  module ConfigurationMethods
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def db
        Blackbeard.db
      end

      def tz
        Blackbeard.tz
      end
    end

    def db
      self.class.db
    end

    def tz
      self.class.tz
    end

  end
end

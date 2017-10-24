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

    def revision_header
      config.revision_header
    end

    def parse_revision(revision_number)
      config.parse_revision_proc.call(revision_number)
    end
  end
end

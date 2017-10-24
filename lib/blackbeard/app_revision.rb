module Blackbeard
  class AppRevision
    include ConfigurationMethods
    include Comparable
    include Chartable

    OLDEST = "0.00"

    attr_reader :comparable_revision, :context

    def initialize(header_string, context = nil)
      @context = context
      @comparable_revision = git_revision_to_comparable(header_string)
    end

    def to_s
      "#{comparable_revision.to_s}"
    end

    alias_method :key, :to_s

    def <=>(target_revision)
      target_version =  Blackbeard::AppRevision.new(target_revision)
      gated = comparable_revision <=> target_version.comparable_revision
      return gated unless context
      target_version.revision.store_query(gated, context)
      gated
    end

    def revision
      @revision ||= Revision.find_or_create(key)
    end

    private

    def git_revision_to_comparable(revision)
      begin
        Gem::Version.new(parse_revision(revision))
      rescue ArgumentError
        Gem::Version.new(OLDEST)
      end
    end

  end
end

module Blackbeard
  class Pirate
    def initialize
      @metrics = {}
      @tests = {}
      @features = {}
      @cohorts = {}
    end

    def metric(type, type_id)
      @metrics["#{type}::#{type_id}"] ||= Metric.find_or_create(type, type_id)
    end

    # TODO: abstract out memoization to a cache class
    def test(id)
      @tests[id] ||= Test.find_or_create(id)
    end

    def cohort(id)
      @cohorts[id] ||= Cohort.find_or_create(id)
    end

    def feature(id)
      @features[id] ||= Feature.find_or_create(id)
    end

    def context(*args)
      Context.new(self, *args)
    end

    def set_context(*args)
      @set_context = context(*args)
    end

    def clear_context
      @set_context = nil
    end

    # TODO: metaprogram all the context delegators
    def add_unique(id)
      return self unless @set_context
      @set_context.add_unique(id)
    end

    def add_total(id, amount)
      return self unless @set_context
      @set_context.add_total(id, amount)
    end

    def add_to_cohort(id, timestamp = nil)
      return self unless @set_context
      @set_context.add_to_cohort(id, timestamp)
    end

    def add_to_cohort!(id, timestamp = nil)
      return self unless @set_context
      @set_context.add_to_cohort!(id, timestamp)
    end

    def ab_test(id, options)
      return self unless @set_context
      @set_context.ab_test(id, options)
    end

    def app_revision
      return AppRevision.new('0', self) unless @set_context
      @set_context.app_revision
    end

    def feature_active?(id, count_participation = true)
      return false unless @set_context
      @set_context.feature_active?(id, count_participation = true)
    end

    def requested_features
      return {} unless @set_context
      @set_context.requested_features
    end


  end
end

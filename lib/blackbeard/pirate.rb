require "blackbeard/context"
require "blackbeard/metric"
require "blackbeard/metric_data/unique"
require "blackbeard/metric_data/total"
require "blackbeard/test"
require "blackbeard/errors"
require "blackbeard/group"

module Blackbeard
  class Pirate
    def initialize
      @metrics = {}
      @tests = {}
    end

    def metric(type, type_id)
      @metrics["#{type}::#{type_id}"] ||= Metric.find_or_create(type, type_id)
    end

    def test(id)
      @tests[id] ||= Test.find_or_create(id)
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

    def add_unique(id)
      return self unless @set_context
      @set_context.add_unique(id)
    end

    def add_total(id, amount)
      return self unless @set_context
      @set_context.add_total(id, amount)
    end

    def ab_test(id, options)
      return self unless @set_context
      @set_context.ab_test(id, options)
    end

    def active?(id)
      return self unless @set_context
      @set_context.active?(id)
    end


  end
end

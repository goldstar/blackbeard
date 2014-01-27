require "blackbeard/context"
require "blackbeard/metric"
require "blackbeard/metric/unique"
require "blackbeard/metric/total"
require "blackbeard/test"
require "blackbeard/errors"

module Blackbeard
  class Pirate
    def initialize
      @total_metrics = {}
      @unique_metrics = {}
      @tests = {}
    end

    def total_metric(id)
      @total_metrics[id] ||= Metric::Total.new(id)
    end

    def unique_metric(id)
      @unique_metrics[id] ||= Metric::Unique.new(id)
    end

    def test(id)
      @tests[id] ||= Test.new(id)
    end


    def context(options = {})
      Context.new(self, options)
    end

    def set_context(options = {})
      @set_context = Context.new(self, options)
    end

    def add_unique(id)
      raise MissingContextError unless @set_context
      @set_context.add_unique(id)
    end

    def add_total(id, amount)
      raise MissingContextError unless @set_context
      @set_context.add_total(id, amount)
    end

    def ab_test(id, options)
      raise MissingContextError unless @set_context
      @set_context.ab_test(id, options)
    end

    def active?(id)
      raise MissingContextError unless @set_context
      @set_context.active?(id)
    end


  end
end

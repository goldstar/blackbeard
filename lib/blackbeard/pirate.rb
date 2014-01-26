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

    def total_metric(name)
      @total_metrics[name] ||= Metric::Total.new(name)
    end

    def unique_metric(name)
      @unique_metrics[name] ||= Metric::Unique.new(name)
    end

    def test(name)
      @tests[name] ||= Test.new(name)
    end


    def context(options = {})
      Context.new(self, options)
    end

    def set_context(options = {})
      @set_context = Context.new(self, options)
    end

    def add_unique(name)
      raise MissingContextError unless @set_context
      @set_context.add_unique(name)
    end

    def add_total(name, amount)
      raise MissingContextError unless @set_context
      @set_context.add_total(name, amount)
    end

    def ab_test(name, options)
      raise MissingContextError unless @set_context
      @set_context.ab_test(name, options)
    end

    def active?(name)
      raise MissingContextError unless @set_context
      @set_context.active?(name)
    end


  end
end

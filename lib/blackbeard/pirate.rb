require "blackbeard/context"
require "blackbeard/metric"
require "blackbeard/metric/unique"
require "blackbeard/metric/total"
require "blackbeard/feature"
require "blackbeard/errors"

module Blackbeard
  class Pirate
    def initialize
      @total_metrics = {}
      @unique_metrics = {}
      @features = {}
    end

    def total_metric(name)
      @total_metrics[name] ||= Metric::Total.new(name)
    end

    def unique_metric(name)
      @unique_metrics[name] ||= Metric::Unique.new(name)
    end

    def feature(name)
      @features[name] ||= Feature.new(name)
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

  end
end

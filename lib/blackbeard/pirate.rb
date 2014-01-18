require "blackbeard/context"
require "blackbeard/metric"
require "blackbeard/metric/unique"
require "blackbeard/metric/total"
require "blackbeard/feature"

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

  end
end

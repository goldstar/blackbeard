require "blackbeard/context"
require "blackbeard/metric"
require "blackbeard/metric/unique"
require "blackbeard/metric/total"

module Blackbeard
  class Pirate
    attr_accessor :total_metrics, :unique_metrics

    def initialize
      @total_metrics = {}
      @unique_metrics = {}
    end

    def total_metric(name)
      @total_metrics[name] ||= Metric::Total.new(name)
    end

    def unique_metric(name)
      @unique_metrics[name] ||= Metric::Unique.new(name)
    end

    def context(options = {})
      Context.new(self, options)
    end

  end
end

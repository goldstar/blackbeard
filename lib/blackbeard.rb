require 'date'
require 'tzinfo'
require 'json'
require 'redis'
require 'redis-namespace'
require 'blackbeard/feature_rollout'
require 'blackbeard/selected_variation'
require 'blackbeard/participant_methods'
require 'blackbeard/configuration'
require 'blackbeard/configuration_methods'
require 'blackbeard/change'
require 'blackbeard/metric_data/uid_generator'
require 'blackbeard/feature_participant_data'
require 'blackbeard/metric_date'
require 'blackbeard/metric_hour'
require 'blackbeard/chartable'
require 'blackbeard/segmented_metric'
require 'blackbeard/cohort_metric'
require 'blackbeard/group_metric'
require 'blackbeard/feature_metric'
require 'blackbeard/storable_has_changes'
require 'blackbeard/storable_attributes'
require 'blackbeard/storable_has_many'
require 'blackbeard/storable_has_set'
require 'blackbeard/storable'
require 'blackbeard/metric_data/base'
require 'blackbeard/participant_methods'
require 'blackbeard/redis_store'
require 'blackbeard/group'
require 'blackbeard/context'
require 'blackbeard/metric'
require 'blackbeard/metric_data/unique'
require 'blackbeard/metric_data/total'
require 'blackbeard/test'
require 'blackbeard/errors'
require 'blackbeard/group'
require 'blackbeard/feature'
require 'blackbeard/cohort'
require 'blackbeard/pirate'
require 'blackbeard/chart'
require 'blackbeard/cohort_data'
require 'blackbeard/app_revision_participant_data'
require 'blackbeard/revision'
require 'blackbeard/app_revision'

module Blackbeard
  class << self

    def configure!
      @config = Configuration.new
      yield config
    end

    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
    end

    def pirate
      Thread.current[:blackbeard_pirate] ||= Blackbeard::Pirate.new
    end

    def walk_the_plank!
      Thread.current[:blackbeard_pirate] = nil
    end
  end
end

Blackbeard.configure! {}

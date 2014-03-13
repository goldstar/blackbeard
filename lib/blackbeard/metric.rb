require "blackbeard/storable"
require 'blackbeard/metric_data/total'
require 'blackbeard/metric_data/unique'
require 'blackbeard/cohort'
require 'blackbeard/group'

module Blackbeard
  class Metric < Storable
    attr_reader :type, :type_id
    set_master_key :metrics
    string_attributes :name, :description
    has_many :groups => Group
    has_many :cohorts => Cohort

    def self.create(type, type_id, options = {})
      super("#{type}::#{type_id}", options)
    end

    def self.find(type, type_id)
      super("#{type}::#{type_id}")
    end

    def self.find_or_create(type, type_id)
      super("#{type}::#{type_id}")
    end

    def initialize(*args)
      if args.size == 1 && args[0] =~ /::/
        @type, @type_id = args[0].split(/::/)
      elsif args.size == 2
        @type = args[0]
        @type_id = args[1]
      else
        raise ArgumentError
      end
      super("#{@type}::#{@type_id}")
    end

    def self.new_from_key(key)
      if key =~ /^#{master_key}::(.+)::(.+)$/
        new($1,$2)
      else
        nil
      end
    end

    def add(context, amount)
      uid = context.unique_identifier
      metric_data.add(uid, amount)
      groups.each do |group|
        segment = group.segment_for(context)
        metric_data(group).add(uid, amount, segment) unless segment.nil?
      end
      cohorts.each do |cohort|
        hour_id = cohort.data.hour_id_for_participant(uid)
        metric_data(cohort).add_at(hour_id, uid, amount) unless hour_id.nil?
      end
    end

    def metric_data(group_or_cohort = nil)
      @metric_data ||= {}
      @metric_data[group_or_cohort && group_or_cohort.key] ||= begin
        if group_or_cohort.nil?
          MetricData.const_get(type.capitalize).new(self, nil, nil)
        elsif group_or_cohort.kind_of?(Group)
          group = group_or_cohort
          raise GroupNotInMetric unless has_group?(group)
          MetricData.const_get(type.capitalize).new(self, group, nil)
        elsif group_or_cohort.kind_of?(Cohort)
          cohort = group_or_cohort
          raise CohortNotInMetric unless has_cohort?(cohort)
          MetricData.const_get(type.capitalize).new(self, nil, cohort)
        else
          raise InvalidMetricData
        end
      end
    end

    def name
      storable_attributes_hash['name'] || type_id
    end

    def addable_groups
      Group.all.reject{ |g| group_ids.include?(g.id) }
    end

    def addable_cohorts
      Cohort.all.reject{ |c| cohort_ids.include?(c.id) }
    end

  end
end

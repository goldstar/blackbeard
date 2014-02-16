require "blackbeard/storable"
require 'blackbeard/metric_data/total'
require 'blackbeard/metric_data/unique'

module Blackbeard
  class Metric < Storable
    attr_reader :type, :type_id
    set_master_key :metrics
    string_attributes :name, :description
    has_many :groups => Group

    def initialize(type, type_id)
      @type = type
      @type_id = type_id
      @metric_data = {}
      super("#{type}::#{type_id}")
    end

    def self.new_from_key(key)
      if key =~ /^#{master_key}::(.+)::(.+)$/
        new($1,$2)
      else
        nil
      end
    end

    def recent_hours
      metric_data.recent_hours
    end

    def recent_days
      metric_data.recent_days
    end

    def add(context, amount)
      uid = context.unique_identifier
      metric_data.add(uid, amount)
      groups.each do |group|
        segment = group.segment_for(context)
        metric_data(group).add(uid, amount, segment) unless segment.nil?
      end
    end

    def metric_data(group = nil)
      @metric_data[group] ||= begin
        raise GroupNotInMetric unless group.nil? || has_group?(group)
        MetricData.const_get(type.capitalize).new(self)
      end
    end

    def name
      storable_attributes_hash['name'] || type_id
    end

    def addable_groups
      Group.all.reject{ |g| group_ids.include?(g.id) }
    end


  end
end

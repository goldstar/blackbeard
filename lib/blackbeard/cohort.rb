require 'blackbeard/storable'
require 'blackbeard/cohort_data'

module Blackbeard
  class Cohort < Storable
    set_master_key :cohorts
    string_attributes :name, :description

    def add(context, timestamp = nil, force = false)
      save if new_record?
      uid = context.unique_identifier
      #TODO: Make sure timestamp is in correct tz
      timestamp ||= tz.now
      return (force) ? data.add_with_force(uid, timestamp) : data.add_without_force(uid, timestamp)
    end

    def data
      @data ||= CohortData.new(self)
    end

    def name
      storable_attributes_hash['name'] || id
    end

  end
end

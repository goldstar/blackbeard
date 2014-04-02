module Blackbeard
  class Group < Storable
    set_master_key :groups
    string_attributes :name, :description
    has_set :segments => :segment

    def name
      storable_attributes_hash['name'] || id
    end

    def segment_for(context)
      return nil unless definition
      segment = definition.call(context.user, context.controller)
      segment_id = case segment
      when  false
        nil
      when nil
        nil
      when true
        self.id
      else
        segment.to_s
      end
      add_segment(segment_id) unless segment_id.nil?
      segment_id
    end

    def definition
      config.group_definitions[self.id.to_sym]
    end

    def metric_data(metric)
      GroupMetric.new(self,metric).metric_data
    end
  end
end

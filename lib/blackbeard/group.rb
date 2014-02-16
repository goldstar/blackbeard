require 'Blackbeard/storable'

module Blackbeard
  class Group < Storable
    set_master_key :groups
    string_attributes :name, :description

    def name
      storable_attributes_hash[:name] || id
    end

    def segment(context)
      return nil unless definition
      raw_segment = definition.call(context.request, context.user)
      segment = case raw_segment
      when false
        nil
      when nil
        nil
      when true
        id
      else
        segment.to_s
      end
      add_segment(segment) unless segment.nil?
      segment
    end

    def definition
      config.group_definitions[self.id.to_sym]
    end

    def add_segment
      # TODO
    end

    def segments
      [] # TODO
    end

  end
end

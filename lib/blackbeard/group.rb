require 'Blackbeard/storable'

module Blackbeard
  class Group < Storable
    set_master_key :groups
    string_attributes :name, :description

    def name
      storable_attributes_hash[:name] || id
    end

    def segments
      []
    end

  end
end

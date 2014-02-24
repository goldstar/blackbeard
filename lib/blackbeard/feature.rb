require 'blackbeard/storable'

module Blackbeard
  class Feature < Storable
    set_master_key :features
    string_attributes :name, :description

    def active?
      false
    end

    def name
      storable_attributes_hash['name'] || id
    end

  private

  end
end

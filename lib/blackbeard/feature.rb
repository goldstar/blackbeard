require 'blackbeard/storable'

module Blackbeard
  class Feature < Storable
    set_master_key :features
    string_attributes :name, :description, :status

    def active_for?(context)
      case status
      when 'active'
        true
      when 'rollout'
        in_active_group?(context) || active_user?(context) || active_visitor?(context)
      else
        false
      end
    end

    def inactive_group?(context)
      false
    end

    def active_user?(context)
      false
    end

    def active_visitor?(context)
      false
    end

    def status
      storable_attributes_hash['status'] || "inactive"
    end

    def name
      storable_attributes_hash['name'] || id
    end

  private

  end
end

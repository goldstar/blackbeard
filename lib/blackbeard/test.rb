module Blackbeard
  class Test < Storable
    set_master_key :tests
    string_attributes :name, :description
    has_set :variations => :variation

    def select_variation
      # add :off unless :off, :control, :default, or :inactive
      :off
    end

  private

    end
end

require 'blackbeard/storable'

module Blackbeard
  class Feature < Storable

private

    def self.master_key
      "features"
    end

  end
end

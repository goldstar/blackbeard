require 'blackbeard/storable'

module Blackbeard
  class Test < Storable

  def add_variation(variation)
    add_variations([variation])
    self
  end

  def add_variations(*new_variations)
    new_variations = new_variations.flatten.map(&:to_s) - variations
    db.set_add_members(variations_set_key, new_variations) if new_variations.any?
    @variations = nil # force a reload next time
    self
  end

  def variations
    @variations ||= db.set_members(variations_set_key) || []
  end

  def select_variation
    # add :off unless :off, :control, :default, or :inactive
    :off
  end

private

    def self.master_key
      "tests"
    end

    def variations_set_key
      "#{key}::variations"
    end

  end
end

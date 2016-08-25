module Blackbeard
  class Test < Storable
    set_master_key :tests
    string_attributes :name, :description
    has_set :variations => :variation
    has_set :participants => :participant
    has_set :finishers => :finisher
    json_attributes :index_moduli

    # NOTE: This calculates the variation on the fly
    def select_variation(unique_identifier = nil)
      # add :off unless :off, :control, :default, or :inactive
      return :off if unique_identifier.nil?

      # calculate index of variation
      index = index_moduli[unique_identifier.to_i(16) % 100] % 2
      variation = ab_variations[index].to_sym
      save_participant(unique_identifier)

      variation
    end

    def self.find(id)
      test = super(id)
      return if test.nil?
      if test.index_moduli.nil? || test.index_moduli.count != 100
        test.index_moduli = (0..99).to_a
      end
      test
    end

    def self.create(id)
      test = super(id)
      test.index_moduli = (0..99).to_a.shuffle
      test.save
      test
    end

    def self.find_or_create(id)
      test = find(id)
      test = create(id) if test.nil?
      test
    end

    def participant_count
      participants.count
    end

    def finishers_count
      finishers.count
    end

    # TODO: Add (3 or more)-part A/B/C... tests, for now, just deal with two variations
    # NOTE: put into canonical dictionary-sorted order for index calculation
    def ab_variations
      variations.sort.reject { |variation|
        %W(off, inactive).member?(variation.to_s)
      }.first(2)
    end

    private

    def save_participant(unique_id)
      return if unique_id.nil?
      unless participants.member?(unique_id)
        participants << unique_id
      end
    end

  end
end

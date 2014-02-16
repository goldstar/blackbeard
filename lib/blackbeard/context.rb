require 'blackbeard/selected_variation'

module Blackbeard
  class Context
    include ConfigurationMethods

    def initialize(pirate, user, request = nil)
      @pirate = pirate
      @request = request
      @user = user

      if (@user == false) || (@user && guest_method && @user.send(guest_method) == false)
        @user = nil
      end
    end

    def add_total(id, amount = 1)
      @pirate.metric(:total, id.to_s).add(unique_identifier, amount)
      self
    end

    def add_unique(id)
      @pirate.metric(:unique, id.to_s).add(unique_identifier)
      self
    end

    def ab_test(id, options = nil)
      test = @pirate.test(id.to_s)
      if options.is_a? Hash
        variation = test.add_variations(options.keys).select_variation
        options[variation.to_sym]
      else
        variation = test.select_variation
        SelectedVariation.new(test, variation)
      end
    end

    def active?(id)
      ab_test(id) == :active
    end

    def unique_identifier
      @user.nil? ? "b#{blackbeard_visitor_id}" : "a#{@user.id}"
    end

private

    def blackbeard_visitor_id
      request.cookies[:bbd] ||= generate_blackbeard_visitor_id
    end

    def generate_blackbeard_visitor_id
      id = Blackbeard.db.increment("visitor_id")
      request.cookies[:bbd] = { :value => id, :expires => Time.now + 31536000 }
      id
    end

  end
end

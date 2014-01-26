require 'blackbeard/selected_variation'

module Blackbeard
  class Context

    def initialize(pirate, options)
      @pirate = pirate
      @user_id = options[:user_id]
      @bot = options[:bot] || false
      @cookies = options[:cookies] || {}
      raise NonIdentifyingContextError unless @cookies || @user_id
    end

    def add_total(name, amount = 1)
      @pirate.total_metric(name.to_s).add(unique_identifier, amount) unless bot?
      self
    end

    def add_unique(name)
      @pirate.unique_metric(name.to_s).add(unique_identifier) unless bot?
      self
    end

    def ab_test(name, options = nil)
      test = @pirate.test(name.to_s)
      if options.is_a? Hash
        variation = test.add_variations(options.keys).select_variation
        options[variation.to_sym]
      else
        variation = test.select_variation
        SelectedVariation.new(test, variation)
      end
    end

    def active?(name)
      ab_test(name) == :active
    end

    def bot?
      @bot
    end

    def unique_identifier
      @user_id.nil? ? "b#{blackbeard_visitor_id}" : "a#{@user_id}"
    end

private

    def blackbeard_visitor_id(cookies)
      @cookies[:bbd] ||= generate_blackbeard_visitor_id(cookies)
    end

    def generate_blackbeard_visitor_id(cookies)
      id = Blackbeard.db.increment("visitor_id")
      @cookies[:bbd] = { :value => id, :expires => Time.now + 31536000 }
      id
    end

  end
end

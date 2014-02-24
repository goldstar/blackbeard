require 'blackbeard/selected_variation'

module Blackbeard
  class Context
    include ConfigurationMethods
    attr_reader :controller, :user

    def initialize(pirate, user, controller = nil)
      @pirate = pirate
      @controller = controller
      @user = user

      if (@user == false) || (@user && guest_method && @user.send(guest_method) == false)
        @user = nil
      end
    end

    def add_total(id, amount = 1)
      @pirate.metric(:total, id.to_s).add(self, amount)
      self
    end

    def add_unique(id)
      @pirate.metric(:unique, id.to_s).add(self, 1)
      self
    end

    def ab_test(id, options = nil)
      test = @pirate.test(id.to_s)
      if options.is_a? Hash
        test.add_variations(options.keys)
        variation = test.select_variation
        options[variation.to_sym]
      else
        variation = test.select_variation
        SelectedVariation.new(test, variation)
      end
    end

    def feature_active?(id)
      @pirate.feature(id.to_s).active?(self)
    end

    def unique_identifier
      @user.nil? ? "b#{blackbeard_visitor_id}" : "a#{@user.id}"
    end

private

    def blackbeard_visitor_id
      controller.request.cookies[:bbd] ||= generate_blackbeard_visitor_id
    end

    def generate_blackbeard_visitor_id
      id = db.increment("visitor_id")
      controller.request.cookies[:bbd] = { :value => id, :expires => Time.now + 31536000 }
      id
    end

  end
end

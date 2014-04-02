module Blackbeard
  class Context
    include ConfigurationMethods
    attr_reader :controller, :user

    def initialize(pirate, user, controller = nil)
      # TODO: remove pirate. access cache via separate cache class
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

    def add_to_cohort(id, timestamp = nil, force = false)
      @pirate.cohort(id.to_s).add(self, timestamp, force)
    end

    def add_to_cohort!(id, timestamp = nil)
      add_to_cohort(id, timestamp, true)
    end

    def feature_active?(id)
      @pirate.feature(id.to_s).reload.active_for?(self)
    end

    def unique_identifier
      @unique_identifier ||= @user.nil? ? "b#{visitor_id}" : "a#{@user.id}"
    end

    def user_id
      @user.id
    end

    def visitor_id
      @visitor_id ||= controller.request.cookies[:bbd] || generate_visitor_id
    end

private

    def generate_visitor_id
      id = db.increment("visitor_id")
      controller.request.cookies[:bbd] = { :value => id, :expires => Time.now + 31536000 }
      id
    end

  end
end

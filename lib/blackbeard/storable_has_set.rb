module Blackbeard
  module StorableHasSet
    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
    end

    module ClassMethods

      def has_set(options = {})
        options.each_pair do |plural, singular|
          _has_set(plural, singular)
        end
      end

      def _has_set(plural, singular)
        plural = plural.to_s.downcase
        singular = singular.to_s.downcase

        methods = <<-END_OF_RUBY

            def has_#{singular}?(o)
              #{plural}.include?(o)
            end

            def add_#{singular}(o)
              db.set_add_member(#{plural}_key, o) unless has_#{singular}?(o)
              \@#{plural} = nil
            end

            def remove_#{singular}(o)
              db.set_remove_member(#{plural}_key, o)
              \@#{plural} = nil
            end

            def #{plural}
              \@#{plural} ||= db.set_members(#{plural}_key)
            end

            def #{plural}_key
              key+"::#{plural}"
            end

        END_OF_RUBY

        class_eval(methods)
      end
    end
  end
end

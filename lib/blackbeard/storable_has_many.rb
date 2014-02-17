module Blackbeard
  module StorableHasMany
    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
    end

    module ClassMethods

      def has_many(options = {})
        options.each_pair do |plural, klass|
          _has_many(plural, klass)
        end
      end

      def _has_many(plural, klass)
        plural = plural.to_s.downcase
        singular = klass.name.split('::').last.downcase

        methods = <<-END_OF_RUBY

            def has_#{singular}?(o)
              #{singular}_ids.include?(o.id)
            end

            def add_#{singular}(o)
              db.set_add_member(#{plural}_set_key, o.key) unless has_#{singular}?(o)
              \@#{plural} = nil
            end

            def remove_#{singular}(o)
              db.set_remove_member(#{plural}_set_key, o.key)
              \@#{plural} = nil
            end

            def #{plural}
              \@#{plural} ||= #{klass.name}.new_from_keys(#{singular}_keys)
            end

            def #{singular}_ids
              #{plural}.map{ |g| g.id }
            end

            def #{singular}_keys
              db.set_members(#{plural}_set_key)
            end

            def #{plural}_set_key
              key+"::#{plural}"
            end
        END_OF_RUBY

        class_eval(methods)
      end
    end
  end
end

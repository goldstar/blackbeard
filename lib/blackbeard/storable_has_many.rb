module Blackbeard
  module StorableHasMany
    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods

      def _add_reciprocal(o)
        singular = self.class._singular_from_klass(o)
        self.send("add_#{singular}".to_sym, o, false) if singular
      end

      def _remove_reciprocal(o)
        singular = self.class._singular_from_klass(o)
        self.send("remove_#{singular}".to_sym, o, false) if singular
      end

    end

    module ClassMethods
      def _singular_from_klass(o)
        @_has_many_lookup ||= {}
        k = o.class.name.split('::').last
        @_has_many_lookup[k]
      end

      def has_many(options = {})
        options.each_pair do |plural, klass|
          _has_many(plural, klass)
        end
      end

      def _has_many(plural, klass)
        @_has_many_lookup ||= {}

        plural = plural.to_s.downcase
        klass_name = klass.is_a?(String) ? klass : klass.name.split('::').last
        singular = plural.gsub(/e?s$/,'')

        @_has_many_lookup[klass_name] = singular

        methods = <<-END_OF_RUBY
            def has_#{singular}?(o)
              #{singular}_ids.include?(o.id)
            end

            def add_#{singular}(o, reciprocate = true)
              unless has_#{singular}?(o)
                db.set_add_member(#{plural}_set_key, o.key)
                log_change("#{plural} added \#{o.name}(\#{o.id})")
              end
              o._add_reciprocal(self) if reciprocate && o.respond_to?(:'_add_reciprocal')
              \@#{plural} = nil
            end

            def remove_#{singular}(o, reciprocate = true)
              if has_#{singular}?(o)
                db.set_remove_member(#{plural}_set_key, o.key)
                log_change("#{plural} removed \#{o.name}(\#{o.id})")
              end
              o._remove_reciprocal(self) if reciprocate && o.respond_to?(:'_remove_reciprocal')
              \@#{plural} = nil
            end

            def #{plural}
              \@#{plural} ||= #{klass_name}.new_from_keys(#{singular}_keys)
            end

            def #{singular}_ids
              #{plural}.map{ |g| g.id }
            end

            def #{singular}_keys
              db.set_members(#{plural}_set_key)
            end

            def #{plural}_set_key
              raise StorableNotSaved if new_record?
              key+"::#{plural}"
            end
        END_OF_RUBY

        class_eval(methods)
      end
    end
  end
end

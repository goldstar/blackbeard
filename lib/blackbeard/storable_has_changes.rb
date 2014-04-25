module Blackbeard
  module StorableHasChanges
    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    module InstanceMethods
      # :storable_class
      # :storable_id
      # :message
      # :timestamp
      def log_change(message)
        log_hash = {
          :message => message,
          :storable_class => self.class.name,
          :storable_id => self.id
        }
        log = Change.log(log_hash)
        db.sorted_set_add_member(changes_sorted_set_key, log[:timestamp], log[:id])
        log
      end

      def changes(limit = nil)
        ids = db.sorted_set_reverse_range_by_score(changes_sorted_set_key, :limit => limit)
        Change.find_all(ids)
      end

      def changes_sorted_set_key
        "#{key}::changes_sorted"
      end
    end

    module ClassMethods
    end
  end
end

module Blackbeard
  class VisitorUserTracker
    include ConfigurationMethods

    def self.get_visitor_id_for_user(user_id)
      str_user_id = db.hash_get(hash_key, user_id)
      str_user_id && str_user_id.to_i
    end

    def self.set_visitor_id_for_user(user_id:, visitor_id:)
      db.hash_set(hash_key, user_id, visitor_id)
    end

    def self.hash_key
      "visitor_user_trackers"
    end

  end
end

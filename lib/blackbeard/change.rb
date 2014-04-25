module Blackbeard
  class Change
    include ConfigurationMethods
    attr_accessor :id, :log

    def initialize(id, log_hash)
      @id = id
      @log = log_hash
    end

    def object
      self.class.const_get(log['storable_class']).find(log['storable_id'])
    end

    def message
      log['message']
    end

    def save
      log['timestamp'] = Time.now.to_i
      db.hash_set(hash_key, id, log.to_json)
      db.sorted_set_add_member(changes_sorted_set_key, log['timestamp'], log['id'])
    end

    def [](attribute)
      return id if attribute.to_s == 'id'
      log[attribute.to_s]
    end

    def self.find(id)
      log_json = db.hash_get(hash_key, id)
      log = JSON.parse(log_json)
      new(id, log)
    end

    def self.find_all(*ids)
      ids = ids.flatten
      log_jsons = db.hash_multi_get(hash_key, ids)
      log_jsons.map do |log_json|
        id = ids.shift
        log_json.nil? ? nil : new(id, JSON.parse(log_json))
      end.compact
    end

    def self.count
      db.hash_length(hash_key)
    end

    def self.last(count = 1)
      upto_id = last_id
      from_id = upto_id - count + 1
      changes = find_all(Array(from_id..upto_id)).reverse
      count == 1 ? changes.first : changes
    end

    def self.log(log)
      id = next_id
      change = new(id, log)
      change.save
      change
    end

    def self.next_id
      db.increment(uid_key)
    end

    def self.last_id
      db.get(uid_key).to_i
    end

    def self.uid_key
      "changes_uid"
    end

    def self.hash_key
      "changes"
    end

    def hash_key
      self.class.hash_key
    end

    def self.changes_sorted_set_key
      "changes_sorted"
    end

    def changes_sorted_set_key
      self.class.changes_sorted_set_key
    end

  end
end

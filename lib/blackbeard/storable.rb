module Blackbeard
  class Storable
    attr_reader :name

    def initialize(name)
      @name = name.to_s.downcase
      db.hash_key_set_if_not_exists(master_key, key, tz.now.to_date)
    end

    def master_key
      raise "define master key in the class that inherits from storable"
    end

    def self.new_from_key(key)
      name = key.split('::').last
      self.new(name)
    end

    def self.all_keys
      db.hash_keys(master_key)
    end

    def self.count
      db.hash_length(master_key)
    end

    def self.all
      all_keys.map{ |key| new_from_key(key) }
    end

  protected

    def key
      "#{master_key}::#{ name }"
    end

    def master_key
      self.class.master_key
    end

    def db
      self.class.db
    end

    def self.db
      Blackbeard.db
    end

    def tz
      self.class.tz
    end

    def self.tz
      Blackbeard.tz
    end
  end
end

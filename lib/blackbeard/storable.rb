require 'blackbeard/configuration_methods'
require 'blackbeard/storable_attributes'
require 'blackbeard/storable_has_many'
require 'blackbeard/storable_has_set'

module Blackbeard
  class Storable
    include ConfigurationMethods
    include StorableHasMany
    include StorableHasSet
    include StorableAttributes

    class << self
      def set_master_key(master_key)
        @master_key = master_key.to_s
      end

      def master_key
        return @master_key if defined? @master_key
        return self.superclass.master_key if self.superclass.respond_to?(:master_key)
        raise StorableMasterKeyUndefined, "define master key in the class that inherits from storable"
      end
    end

    attr_reader :id

    def initialize(id)
      @id = id.to_s.downcase
      db.hash_key_set_if_not_exists(master_key, key, tz.now.to_date)
    end

    def self.all_keys
      db.hash_keys(master_key)
    end

    def self.count
      db.hash_length(master_key)
    end

    def self.new_from_keys(*keys)
      keys.flatten.map{ |key| new_from_key(key) }
    end

    def self.new_from_key(key)
      if key =~ /^#{master_key}::(.+)$/
        new($1)
      else
        nil
      end
    end

    def self.all
      all_keys.map{ |key| new_from_key(key) }
    end

    def ==(o)
      o.class == self.class && o.id == self.id
    end

    def key
      "#{master_key}::#{ id }"
    end

    def master_key
      self.class.master_key
    end

  end
end

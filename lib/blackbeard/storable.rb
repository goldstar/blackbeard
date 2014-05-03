module Blackbeard
  class Storable
    include ConfigurationMethods

    class << self
      def set_master_key(master_key)
        @master_key = master_key.to_s
      end

      def master_key
        return @master_key if defined? @master_key
        return self.superclass.master_key if self.superclass.respond_to?(:master_key)
        raise StorableMasterKeyUndefined, "define master key in the class that inherits from storable"
      end

      def on_save(method)
        on_save_methods.push(method)
      end

      def on_save_methods
        @on_save_methods ||= self.superclass.on_save_methods.dup if self.superclass.respond_to?(:on_save_methods)
        @on_save_methods ||= []
      end

      def on_reload(method)
        on_reload_methods.push(method)
      end

      def on_reload_methods
        @on_reload_methods ||= self.superclass.on_reload_methods.dup if self.superclass.respond_to?(:on_reload_methods)
        @on_reload_methods ||= []
      end
    end

    attr_reader :id
    attr_accessor :new_record

    include StorableHasMany
    include StorableHasSet
    include StorableAttributes
    include StorableHasChanges

    def initialize(id)
      @id = id.to_s.downcase
      @new_record = true
    end

    def self.find(id)
      key = key_for(id)
      return nil unless db.hash_field_exists(master_key, key)
      storable = new(id)
      storable.new_record = false
      storable
    end

    def self.create(id, attributes = {})
      key = key_for(id)
      raise StorableDuplicateKey if db.hash_field_exists(master_key, key)
      storable = new(id)
      storable.save
      storable.update_attributes(attributes) unless attributes.empty?
      storable
    end

    def self.find_or_create(id)
      storable = new(id)
      storable.save
      storable
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
        storable = new($1)
        storable.new_record = false
        storable
      else
        nil
      end
    end

    def self.all
      all_keys.map{ |key| new_from_key(key) }
    end

    def save
      if new_record?
        db.hash_set_if_not_exists(master_key, key, tz.now.to_date) and log_change("was created")
        @new_record = false
      end
      self.class.on_save_methods.each{ |m| self.send(m) }
      true
    end

    def reload
      self.class.on_reload_methods.each{ |m| self.send(m) }
      self
    end

    def new_record?
      @new_record
    end

    def ==(o)
      o.class == self.class && o.id == self.id
    end

    def self.key_for(id)
      "#{master_key}::#{ id.to_s.downcase }"
    end

    def key
      self.class.key_for(id)
    end

    def master_key
      self.class.master_key
    end

    def storable_type
      self.class.name.split(/::/).last
    end

    def path
      "#{self.class.master_key}/#{self.id}"
    end

  end
end

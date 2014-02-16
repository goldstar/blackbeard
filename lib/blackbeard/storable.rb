require 'blackbeard/configuration_methods'
require 'blackbeard/storable_has_many'

module Blackbeard
  class Storable
    include ConfigurationMethods
    extend StorableHasMany

    class << self
      def set_master_key(master_key)
        @master_key = master_key.to_s
      end

      def master_key
        return @master_key if defined? @master_key
        return self.superclass.master_key if self.superclass.respond_to?(:master_key)
        raise StorableMasterKeyUndefined, "define master key in the class that inherits from storable"
      end

      def storable_attributes=(x)
        @storable_attributes = x
      end

      def storable_attributes
        return @storable_attributes if defined? @storable_attributes
        return self.superclass.storable_attributes if self.superclass.respond_to?(:storable_attributes)
        []
      end

      def string_attributes(*attributes)
        self.storable_attributes += attributes
        attributes.each do |method_name|
          method_name = method_name.to_sym
          send :define_method, method_name do
            storable_attributes_hash[method_name.to_s]
          end
          send :define_method, "#{method_name}=".to_sym do |value|
            db.hash_set(attributes_hash_key, method_name, value)
            storable_attributes_hash[method_name.to_s] = value
          end
        end
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

    def update_attributes(tainted_params)
      attributes = self.class.storable_attributes
      safe_attributes = tainted_params.keys.select{ |k| attributes.include?(k.to_sym) }
      safe_attributes.each do |attribute|
        self.send("#{attribute}=".to_sym, tainted_params[attribute])
      end
    end

    def key
      "#{master_key}::#{ id }"
    end

protected

    def storable_attributes_hash
      @storable_attributes ||= db.hash_get_all(attributes_hash_key)
    end

    def attributes_hash_key
      "#{key}::attributes"
    end

    def master_key
      self.class.master_key
    end

  end
end

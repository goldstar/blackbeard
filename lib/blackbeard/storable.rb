module Blackbeard
  class Storable

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
        @storable_attributes || []
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

    def self.new_from_id(key)
      id = key.split('::').last
      self.new(id)
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

    def storable_attributes_hash
      @storable_attributes ||= db.hash_get_all(attributes_hash_key)
    end

    def attributes_hash_key
      "#{key}::attributes"
    end

    def key
      "#{master_key}::#{ id }"
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

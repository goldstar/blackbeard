require 'json'

module Blackbeard
  module StorableAttributes
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
      base.send :on_save, :save_storable_attributes
    end

    module ClassMethods
      def storable_attributes=(x)
        @storable_attributes = x
      end

      def storable_attributes
        return @storable_attributes if defined? @storable_attributes
        return self.superclass.storable_attributes if self.superclass.respond_to?(:storable_attributes)
        []
      end

      def integer_attributes(*attributes)
        self.storable_attributes += attributes
        attributes.each do |method_name|
          method_name = method_name.to_sym
          send :define_method, method_name do
            storable_attributes_hash[method_name.to_s].to_i
          end
          send :define_method, "#{method_name}=".to_sym do |value|
            storable_attributes_hash[method_name.to_s] = value.to_i.to_s
            @storable_attributes_dirty = true
          end
        end
      end

      def json_attributes(*attributes)
        self.storable_attributes += attributes
        attributes.each do |method_name|
          method_name = method_name.to_sym
          send :define_method, method_name do
            return nil if storable_attributes_hash[method_name.to_s].nil?
            JSON.parse(storable_attributes_hash[method_name.to_s])
          end
          send :define_method, "#{method_name}=".to_sym do |value|
            storable_attributes_hash[method_name.to_s] =  JSON.generate(value)
            @storable_attributes_dirty = true
          end
        end
      end

      def string_attributes(*attributes)
        self.storable_attributes += attributes
        attributes.each do |method_name|
          method_name = method_name.to_sym
          send :define_method, method_name do
            storable_attributes_hash[method_name.to_s]
          end
          send :define_method, "#{method_name}=".to_sym do |value|
            storable_attributes_hash[method_name.to_s] = value.to_s
            @storable_attributes_dirty = true
          end
        end
      end
    end

    module InstanceMethods
      def update_attributes(tainted_params)
        attributes = self.class.storable_attributes
        safe_attributes = tainted_params.keys.select{ |k| attributes.include?(k.to_sym) }
        safe_attributes.each do |attribute|
          self.send("#{attribute}=".to_sym, tainted_params[attribute])
        end
        save_storable_attributes
      end

      def save_storable_attributes
        raise StorableNotSaved if new_record?
        if @storable_attributes_dirty
          db.hash_multi_set(attributes_hash_key, storable_attributes_hash)
          @storable_attributes_dirty = false
        end
      end

      def storable_attributes_hash
        @storable_attributes ||= db.hash_get_all(attributes_hash_key)
      end

      def attributes_hash_key
        "#{key}::attributes"
      end

    end

  end
end

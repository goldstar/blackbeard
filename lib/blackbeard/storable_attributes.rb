module Blackbeard
  module StorableAttributes
    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
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

    module InstanceMethods
      def update_attributes(tainted_params)
        attributes = self.class.storable_attributes
        safe_attributes = tainted_params.keys.select{ |k| attributes.include?(k.to_sym) }
        safe_attributes.each do |attribute|
          self.send("#{attribute}=".to_sym, tainted_params[attribute])
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
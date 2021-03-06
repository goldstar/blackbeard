module Blackbeard
  module StorableAttributes
    def self.included(base)
      base.extend ClassMethods
      base.send :include, InstanceMethods
      base.send :on_save, :save_storable_attributes
      base.send :on_reload, :reload_storable_attributes
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
          send :define_method, "#{method_name}=".to_sym do |new_value|
            __update_storable_attribute(method_name.to_s, new_value.to_i)
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
          send :define_method, "#{method_name}=".to_sym do |new_value|
            __update_storable_attribute(method_name.to_s, JSON.generate(new_value))
          end
        end
      end

      def string_attributes(*attributes)
        self.storable_attributes += attributes
        attributes.each do |method_name|
          method_name = method_name.to_sym
          send :define_method, method_name do
            storable_attributes_hash[method_name.to_s]
          end unless method_name.to_s == 'name'
          send :define_method, "#{method_name}=".to_sym do |new_value|
            __update_storable_attribute(method_name.to_s, new_value.to_s)
          end
        end
      end
    end

    module InstanceMethods

      def name
        storable_attributes_hash['name'] || id
      end

      def __update_storable_attribute(attribute, value)
        original_value = storable_attributes_hash[attribute].to_s
        value = value.to_s
        if original_value != value
          storable_attributes_hash[attribute] = value
          @storable_attributes_changes ||= {}
          @storable_attributes_changes[attribute] = value
        end
      end

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
        if @storable_attributes_changes
          db.hash_multi_set(attributes_hash_key, @storable_attributes_changes)
          @storable_attributes_changes.keys.each do |k|
            log_change("#{k} was changed to #{@storable_attributes_changes[k]}")
          end
          @storable_attributes_changes = nil
        end
      end

      def reload_storable_attributes
        @storable_attributes = nil
        @storable_attributes_changes = nil
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

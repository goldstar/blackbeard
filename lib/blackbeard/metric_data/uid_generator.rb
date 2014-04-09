module Blackbeard
  module MetricData
    class UidGenerator
      include ConfigurationMethods

      def initialize(metric_data)
        @metric = metric_data.metric
        @metric_for = metric_data.metric_for
      end

      def uid
        db.hash_get(lookup_hash, lookup_field) || generate_uid
      end

    private

      def lookup_hash
        "metric_data_keys"
      end

      def lookup_field
        lookup_field = "metric-#{@metric.id}"
        lookup_field += "::#{@metric_for.class.name.split('::').last}-#{@metric_for.id}" if @metric_for
        lookup_field
      end

      def generate_uid
        uid = db.increment("metric_data_next_uid")
        # write and read to avoid race conditional writes
        db.hash_set_if_not_exists(lookup_hash, lookup_field, uid)
        db.hash_get(lookup_hash, lookup_field)
      end

    end
  end
end

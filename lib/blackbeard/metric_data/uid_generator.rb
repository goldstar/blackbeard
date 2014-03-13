module Blackbeard
  module MetricData
    class UidGenerator
      include ConfigurationMethods

      def initialize(metric_data)
        @metric = metric_data.metric
        @group = metric_data.group
        @cohort = metric_data.cohort
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
        lookup_field += "::group-#{@group.id}" if @group
        lookup_field += "::group-#{@cohort.id}" if @cohort
        lookup_field
      end

      def generate_uid
        uid = db.increment("metric_data_next_uid")
        # write and read to avoid race conditional writes
        db.hash_key_set_if_not_exists(lookup_hash, lookup_field, uid)
        db.hash_get(lookup_hash, lookup_field)
      end

    end
  end
end

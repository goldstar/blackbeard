module Blackbeard
  class Metric < Storable
    include Chartable

    attr_reader :type, :type_id
    set_master_key :metrics
    string_attributes :name, :description
    has_many :groups => 'Group'
    has_many :cohorts => 'Cohort'
    has_many :features => 'Feature'

    def self.create(type, type_id, options = {})
      super("#{type}::#{type_id}", options)
    end

    def self.find(type, type_id = nil)
      if type_id.nil?
        super(type)
      else
        super("#{type}::#{type_id}")
      end
    end

    def self.find_or_create(type, type_id)
      super("#{type}::#{type_id}")
    end

    def path
      "#{self.class.master_key}/#{type}/#{type_id}"
    end

    def initialize(*args)
      if args.size == 1 && args[0] =~ /::/
        @type, @type_id = args[0].split(/::/)
      elsif args.size == 2
        @type = args[0]
        @type_id = args[1]
      else
        raise ArgumentError
      end
      super("#{@type}::#{@type_id}")
    end

    def self.new_from_key(key)
      if key =~ /^#{master_key}::(.+)::(.+)$/
        new($1,$2)
      else
        nil
      end
    end

    def group_metrics
      groups.map{ |g| GroupMetric.new(g, self) }
    end

    def cohort_metrics
      cohorts.map{ |c| CohortMetric.new(c, self) }
    end

    def feature_metrics
      features.map{ |f| FeatureMetric.new(f, self) }
    end

    def submetrics
      [group_metrics, cohort_metrics, feature_metrics].flatten
    end


    def add(context, amount)
      uid = context.unique_identifier
      metric_data.add(uid, amount)
      submetrics.each{ |submetric| submetric.add(context, amount) }
    end

    def metric_data
      @metric_data ||= MetricData.const_get(type.capitalize).new(self)
    end

    def name
      storable_attributes_hash['name'] || type_id
    end

    def addable_groups
      Group.all.reject{ |g| group_ids.include?(g.id) }
    end

    def addable_cohorts
      Cohort.all.reject{ |c| cohort_ids.include?(c.id) }
    end

    def chartable_segments
      metric_data.segments
    end

    def chartable_result_for_hour(hour)
      metric_data.result_for_hour(hour)
    end

    def chartable_result_for_day(date)
      metric_data.result_for_day(date)
    end

  end
end

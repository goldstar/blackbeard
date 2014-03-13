require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  module MetricData
    describe Chartable do

      class ExampleChartable
        include Chartable

        def result_for_day(day)
          {'segment1' => 0}
        end

        def result_for_hour(hour)
          {'segment1' => 0}
        end

        def segments
          ['segment1']
        end

      end

      let(:example){ ExampleChartable.new }

      describe "recent_hours" do
        let(:start_at) { Time.new(2014,1,1,12,0,0) }

        it "should return results for recent hours" do
          example.recent_hours(3, start_at).should have(3).metric_hours
        end
      end

      describe "recent_days" do
        let(:start_on) { Date.new(2014,1,3) }

        it "should return results for recent days" do
          example.recent_days(3, start_on).should have(3).metric_days
        end
      end

      describe "recent_hours_chart" do
        it "should return a chart obj" do
          example.recent_hours_chart.should be_a(Chart)
        end
      end

      describe "recent_days_chart" do
        it "should return a chart obj" do
          example.recent_days_chart.should be_a(Chart)
        end
      end

    end
  end
end

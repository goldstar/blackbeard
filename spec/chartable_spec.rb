require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  module MetricData
    describe Chartable do

      class ExampleChartable
        include Chartable

        def chartable_result_for_day(day)
          {'segment1' => 0}
        end

        def chartable_result_for_hour(hour)
          {'segment1' => 0}
        end

        def chartable_segments
          ['segment1']
        end

      end

      let(:example){ ExampleChartable.new }

      describe "recent_hours" do
        let(:start_at) { Time.new(2014,1,1,12,0,0) }

        it "should return results for recent hours" do
          expect(example.recent_hours(3, start_at).size).to eq(3)
        end
      end

      describe "recent_days" do
        let(:start_on) { Date.new(2014,1,3) }

        it "should return results for recent days" do
          expect(example.recent_days(3, start_on).size).to eq(3)
        end
      end

      describe "recent_hours_chart" do
        it "should return a chart obj" do
          expect(example.recent_hours_chart).to be_a(Chart)
        end
      end

      describe "recent_days_chart" do
        it "should return a chart obj" do
          expect(example.recent_days_chart).to be_a(Chart)
        end
      end

    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Blackbeard
  module MetricData
    describe Base do
      let(:metric) { Blackbeard::Metric.new(:total, "one-total") }
      let(:metric2) { Blackbeard::Metric.new(:total, "two-total") }
      let(:metric_data) { metric.metric_data }

      describe "key" do
        it "should auto increment" do
          expect(metric_data.key).to eq("data::1")
          expect(metric2.metric_data.key).to eq("data::2")
        end
      end

      describe "hour_keys" do

        it "should return an empty array if no metrics" do
          expect(metric_data.send(:hour_keys)).to eq([])
        end

        it "should return an array for each hour" do
          metric_data.add('user1', 1)
          key = metric_data.send(:key_for_hour, tz.now)
          expect(metric_data.send(:hour_keys).size).to eq(1)
        end
      end

      describe "hour_keys_for_day" do
        it "should return 1 key for every hour from morning to night" do
            keys_for_day = metric_data.hour_keys_for_day(Date.new(2014,1,1))
            expect(keys_for_day.size).to eq(24)
            expect(keys_for_day.first).to eq(metric_data.send(:key_for_hour, Time.new(2014,1,1,0,0,0)))
            expect(keys_for_day.last).to eq(metric_data.send(:key_for_hour, Time.new(2014,1,1,23,0,0)))
        end
      end

    end
  end
end

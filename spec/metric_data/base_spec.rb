require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Blackbeard
  module MetricData
    describe Base do
      let(:metric) { Blackbeard::Metric.new(:total, "one-total") }
      let(:metric2) { Blackbeard::Metric.new(:total, "two-total") }
      let(:metric_data) { metric.metric_data }

      describe "key" do
        it "should auto increment" do
          metric_data.key.should == "data::1"
          metric2.metric_data.key.should == "data::2"
        end
      end

      describe "hour_keys" do

        it "should return an empty array if no metrics" do
          metric_data.send(:hour_keys).should == []
        end

        it "should return an array for each hour" do
          metric_data.add('user1', 1)
          key = metric_data.send(:key_for_hour, tz.now)
          metric_data.send(:hour_keys).should have(1).key
        end
      end

      describe "hour_keys_for_day" do
        it "should return 1 key for every hour from morning to night" do
            keys_for_day = metric_data.hour_keys_for_day(Date.new(2014,1,1))
            keys_for_day.should have(24).keys
            keys_for_day.first.should == metric_data.send(:key_for_hour, Time.new(2014,1,1,0,0,0))
            keys_for_day.last.should == metric_data.send(:key_for_hour, Time.new(2014,1,1,23,0,0))
        end
      end

    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Blackbeard
  module MetricData

    describe UidGenerator do
      let(:metric) { Blackbeard::Metric.new(:total, "one-total") }
      let(:metric2) { Blackbeard::Metric.new(:total, "two-total") }
      let(:metric_data) { metric.metric_data }
      let(:metric_data2) { metric2.metric_data }

      context "already existing uid" do
        it "should return the existing uid" do
          UidGenerator.new(metric_data).uid.should == UidGenerator.new(metric_data).uid
        end
      end
      context "new metric_data" do
        it "should increment to the next uid" do
          uid = UidGenerator.new(metric_data).uid
          UidGenerator.new(metric_data2).uid.to_i.should == uid.to_i + 1
        end
      end
    end

  end
end

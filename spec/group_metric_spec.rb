require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe GroupMetric do
    let(:metric) { Metric.create(:total, "one-total") }
    let(:group) { Group.create(:example) }
    let(:metric_data) { group_metric.metric_data }
    # let(:group_metric_data) { metric.metric_data(group) }
    let(:group_metric){ GroupMetric.new( group, metric) }
    describe "add" do
      let(:context) { double(:unique_identifier => 'uid', :controller => double, :user => double) }

      it "should increment metric data" do
        group.stub(:segment_for).and_return("segment")
        metric_data.should_receive(:add).with("uid",1, "segment")
        group_metric.add(context, 1)
      end

      it "should not increment nil segments" do
        group.stub(:segment_for).and_return(nil)
        metric_data.should_not_receive(:add).with("uid",1, "segment")
        group_metric.add(context, 1)
      end
    end
  end
end

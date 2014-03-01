require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe Metric do
    let(:metric) { Metric.create(:total, "one-total") }
    let(:group) { Group.create(:example) }
    let(:metric_data) { metric.metric_data }
    let(:group_metric_data) { metric.metric_data(group) }

    describe "self.all" do
      before :each do
        Metric.create(:total, "one-total")
        Metric.create(:total, "two-total")
        Metric.create(:unique, "one-unique")
      end
      it "should return a Metric Object for each Metric created" do
        Metric.all.should have(3).metrics
      end
    end

    describe "add" do
      let(:context) { double(:unique_identifier => 'uid', :controller => double, :user => double) }
      before :each do
        metric.stub(:groups).and_return([group])
      end

      it "should increment metric data" do
        metric_data.should_receive(:add).with("uid",1)
        metric.add(context, 1)
      end

      it "should increment metric data for each group" do
        group.stub(:segment_for).and_return("segment")
        group_metric_data.should_receive(:add).with("uid", 1, "segment" )
        metric.add(context, 1)
      end

      it "should not increment nil segments" do
        group.stub(:segment_for).and_return(nil)
        group_metric_data.should_not_receive(:add)
        metric.add(context, 1)
      end
    end

    describe "addable_groups" do
      it "should include the groups not added" do
        group # to initialize it
        metric.addable_groups.map{|g| g.id }.should include(group.id)
      end

      it "should not include the group added" do
        metric.add_group(group)
        metric.addable_groups.map{|g| g.id }.should_not include(group.id)
      end
    end

  end
end

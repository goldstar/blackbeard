require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe Metric do
    let(:metric) { Metric.new(:total, "one-total") }
    let(:group) { Group.new(:example) }

    describe "self.all" do
      before :each do
        Metric.new(:total, "one-total")
        Metric.new(:total, "two-total")
        Metric.new(:unique, "one-unique")
      end
      it "should return a Metric Object for each Metric created" do
        Metric.all.should have(3).metrics
      end
    end

    describe "add" do
      it "should increment metric data" do
        metric.metric_data.should_receive(:add).with("uid",1)
        metric.add("uid", 1)
      end
    end

    describe "groups" do
      it "should return an empty array for no groups" do
        metric.groups.should == []
      end

      it "should return the groups when there are groups" do
        metric.add_group(group)
        metric.groups.map{|g| g.id}.should == [group.id]
      end
    end

    describe "add_group" do
      it "should add the group to the metric" do
        expect{
          metric.add_group(group)
          }.to change{ metric.groups.count }.by(1)
      end
    end

    describe "remove_group" do
      it "should remove the group from the metric" do
        metric.add_group(group)
        expect{
          metric.remove_group(group)
        }.to change{ metric.groups.count }.by(-1)
      end
      it "should remove all the group metric data"
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


    describe "has_group?" do
      it "should return true if metric has group" do
        expect{
          metric.add_group(group)
        }.to change{ metric.has_group?(group) }.from(false).to(true)
      end
    end

  end
end

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe Metric do
    let(:metric) { Metric.create(:total, "one-total") }
    let(:metric_data) { metric.metric_data }

    describe "self.all" do
      before :each do
        Metric.create(:total, "one-total")
        Metric.create(:total, "two-total")
        Metric.create(:unique, "one-unique")
      end
      it "should return a Metric Object for each Metric created" do
        expect(Metric.all.size).to eq(3)
      end
    end

    describe "add" do
      let(:context) { double(:unique_identifier => 'uid', :controller => double, :user => double) }

      it "should increment metric data" do
        expect(metric_data).to receive(:add).with("uid",1)
        metric.add(context, 1)
      end

      it "should call add on all group metrics" do
        group_metric = double
        expect(metric).to receive(:group_metrics).and_return([group_metric])
        expect(group_metric).to receive(:add).with(context, 1)
        metric.add(context, 1)
      end

      it "should call add on all cohort metrics" do
        cohort_metric = double
        expect(metric).to receive(:cohort_metrics).and_return([cohort_metric])
        expect(cohort_metric).to receive(:add).with(context, 1)
        metric.add(context, 1)
      end

      it "should call add on all the feature metrics" do
        feature_metric = double
        expect(metric).to receive(:feature_metrics).and_return([feature_metric])
        expect(feature_metric).to receive(:add).with(context, 1)
        metric.add(context, 1)
      end

    end

    describe "addable_groups" do
      let!(:group) { Group.create(:example) }
      it "should include the groups not added" do
        expect(metric.addable_groups.map{|g| g.id }).to include(group.id)
      end

      it "should not include the group added" do
        metric.add_group(group)
        expect(metric.addable_groups.map{|g| g.id }).not_to include(group.id)
      end
    end

    describe "addable_cohorts" do
      let!(:cohort){ Cohort.create(:example)}

      it "should include the groups not added" do
        expect(metric.addable_cohorts.map{|g| g.id }).to include(cohort.id)
      end

      it "should not include the group added" do
        metric.add_cohort(cohort)
        expect(metric.addable_cohorts.map{|c| c.id }).not_to include(cohort.id)
      end
    end

  end
end

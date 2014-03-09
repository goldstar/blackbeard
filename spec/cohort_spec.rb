require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe Cohort do
    let(:uid){ "an id" }
    let(:hour){ Time.new(2014,3,5,1) }
    let(:cohort) { Cohort.new(:happy) }
    let(:cohort_data) { CohortData.new(cohort) }

    describe "add" do
      let(:context){ double :unique_identifier => uid }
      before :each do
        cohort.stub(:data).and_return(cohort_data)
      end

      it "should save the cohort if its new" do
        cohort.should_receive(:save)
        cohort.add(context)
      end
      it "should call add_with_force if forced used" do
        cohort_data.should_receive(:add_with_force).with(uid, hour).and_return(true)
        cohort.add(context, hour, true).should be_true
      end
      it "should call add_without_force if not forced used" do
        cohort_data.should_receive(:add_without_force).with(uid, hour).and_return(true)
        cohort.add(context, hour).should be_true
      end
    end

  end
end

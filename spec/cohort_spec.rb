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
        allow(cohort).to receive(:data).and_return(cohort_data)
      end

      it "should save the cohort if its new" do
        expect(cohort).to receive(:save)
        cohort.add(context)
      end
      it "should call add_with_force if forced used" do
        expect(cohort_data).to receive(:add_with_force).with(uid, hour).and_return(true)
        expect(cohort.add(context, hour, true)).to be_truthy
      end
      it "should call add_without_force if not forced used" do
        expect(cohort_data).to receive(:add_without_force).with(uid, hour).and_return(true)
        expect(cohort.add(context, hour)).to be_truthy
      end
    end

  end
end

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe Cohort do
    let(:uid){ "an id" }
    let(:hour_id){ "2014030503" }
    let(:different_hour_id){ "2014030502" }
    let(:cohort) { Cohort.new(:happy) }

    describe "add" do
      let(:context){ double :unique_identifier => uid }
      before :each do
        cohort.stub(:field_for_hour).and_return(hour_id)
      end
      it "should save the cohort if its new" do
        cohort.should_receive(:save)
        cohort.add(context)
      end
      it "should call add_with_force if forced used" do
        cohort.should_receive(:add_with_force).with(uid, hour_id).and_return(true)
        cohort.add(context, nil, true).should be_true
      end
      it "should call add_without_force if not forced used" do
        cohort.should_receive(:add_without_force).with(uid, hour_id).and_return(true)
        cohort.add(context).should be_true
      end
    end

    describe "#add with force" do
      context "no pre-existing cohort" do
        it "should call add without force" do
          cohort.should_receive(:add_without_force).with(uid, hour_id)
          cohort.send(:add_with_force, uid, hour_id)
        end
        it "should return true" do
          cohort.send(:add_with_force, uid, hour_id).should be_true
        end
      end

      context "already in same cohort" do
        before :each do
          cohort.send(:add_without_force, uid, hour_id)
        end
        it "should not increment the hours" do
          expect{
            cohort.send(:add_with_force, uid, hour_id)
          }.to_not change{ cohort.participants_for_hour(hour_id) }
        end
        it "should not update the participants" do
          expect{
            cohort.send(:add_with_force, uid, hour_id)
          }.to_not change{ cohort.hour_id_for_participant(uid) }
        end
        it "should return true" do
          cohort.send(:add_with_force, uid, hour_id).should be_true
        end
      end

      context "already in different cohort" do
        before :each do
          cohort.send(:add_without_force, uid, different_hour_id)
        end
        it "should de-increment the existing hour field" do
          expect{
            cohort.send(:add_with_force, uid, hour_id)
          }.to change{ cohort.participants_for_hour(different_hour_id) }.by(-1)
        end
        it "should increment the new hour field" do
          expect{
            cohort.send(:add_with_force, uid, hour_id)
          }.to change{ cohort.participants_for_hour(hour_id) }.by(1)
        end
        it "should update the participant to the current hour" do
          expect{
            cohort.send(:add_with_force, uid, hour_id)
          }.to change{ cohort.hour_id_for_participant(uid) }.from(different_hour_id).to(hour_id)
        end
      end
    end

    describe "#add without force" do
      context "already in cohort" do
        before :each do
          cohort.send(:add_without_force, uid, different_hour_id)
        end
        it "should not update the paricipant to the current hour" do
          expect{
            cohort.send(:add_without_force, uid, hour_id)
          }.to_not change{ cohort.hour_id_for_participant(uid) }
        end
        it "should not increment the new hour field" do
          expect{
            cohort.send(:add_without_force, uid, hour_id)
          }.to_not change{ cohort.participants_for_hour(hour_id) }
        end
        it "should return false" do
          cohort.send(:add_without_force, uid, hour_id).should be_false
        end
      end

      context "not in cohort" do
        it "should update the participant to the current hour" do
          expect{
            cohort.send(:add_without_force, uid, hour_id)
          }.to change{ cohort.hour_id_for_participant(uid) }.from(nil).to(hour_id)
        end
        it "should increment the new hour field" do
          expect{
            cohort.send(:add_without_force, uid, hour_id)
          }.to change{ cohort.participants_for_hour(hour_id) }.by(1)
        end
        it "should return true" do
          cohort.send(:add_without_force, uid, hour_id).should be_true
        end
      end
    end
  end
end

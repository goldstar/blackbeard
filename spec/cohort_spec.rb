require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe Cohort do
    let(:uid){ "an id" }
    let(:hour){ Time.new(2014,3,5,1) }
    let(:hour_id){ cohort.send(:hour_id, hour)}
    let(:different_hour){ Time.new(2014,3,5,2) }
    let(:different_hour_id){ cohort.send(:hour_id, different_hour)}
    let(:cohort) { Cohort.new(:happy) }

    describe "add" do
      let(:context){ double :unique_identifier => uid }
      # before :each do
      #   cohort.stub(:field_for_hour).and_return(hour)
      # end
      it "should save the cohort if its new" do
        cohort.should_receive(:save)
        cohort.add(context)
      end
      it "should call add_with_force if forced used" do
        cohort.should_receive(:add_with_force).with(uid, hour).and_return(true)
        cohort.add(context, hour, true).should be_true
      end
      it "should call add_without_force if not forced used" do
        cohort.should_receive(:add_without_force).with(uid, hour).and_return(true)
        cohort.add(context, hour).should be_true
      end
    end

    describe "#add with force" do
      context "no pre-existing cohort" do
        it "should call add without force" do
          cohort.should_receive(:add_without_force).with(uid, hour)
          cohort.send(:add_with_force, uid, hour)
        end
        it "should return true" do
          cohort.send(:add_with_force, uid, hour).should be_true
        end
      end

      context "already in same cohort" do
        before :each do
          cohort.send(:add_without_force, uid, hour)
        end
        it "should not increment the hours" do
          expect{
            cohort.send(:add_with_force, uid, hour)
          }.to_not change{ cohort.participants_for_hour(hour) }
        end
        it "should not update the participants" do
          expect{
            cohort.send(:add_with_force, uid, hour)
          }.to_not change{ cohort.hour_id_for_participant(uid) }
        end
        it "should return true" do
          cohort.send(:add_with_force, uid, hour).should be_true
        end
      end

      context "already in different cohort" do
        before :each do
          cohort.send(:add_without_force, uid, different_hour)
        end
        it "should de-increment the existing hour field" do
          expect{
            cohort.send(:add_with_force, uid, hour)
          }.to change{ cohort.participants_for_hour(different_hour) }.by(-1)
        end
        it "should increment the new hour field" do
          expect{
            cohort.send(:add_with_force, uid, hour)
          }.to change{ cohort.participants_for_hour(hour) }.by(1)
        end
        it "should update the participant to the current hour" do
          expect{
            cohort.send(:add_with_force, uid, hour)
          }.to change{ cohort.hour_id_for_participant(uid) }.from(different_hour_id).to(hour_id)
        end
      end
    end

    describe "#add without force" do
      context "already in cohort" do
        before :each do
          cohort.send(:add_without_force, uid, different_hour)
        end
        it "should not update the paricipant to the current hour" do
          expect{
            cohort.send(:add_without_force, uid, hour)
          }.to_not change{ cohort.hour_id_for_participant(uid) }
        end
        it "should not increment the new hour field" do
          expect{
            cohort.send(:add_without_force, uid, hour)
          }.to_not change{ cohort.participants_for_hour(hour) }
        end
        it "should return false" do
          cohort.send(:add_without_force, uid, hour).should be_false
        end
      end

      context "not in cohort" do
        it "should update the participant to the current hour" do
          expect{
            cohort.send(:add_without_force, uid, hour)
          }.to change{ cohort.hour_id_for_participant(uid) }.from(nil).to(hour_id)
        end
        it "should increment the new hour field" do
          expect{
            cohort.send(:add_without_force, uid, hour)
          }.to change{ cohort.participants_for_hour(hour) }.by(1)
        end
        it "should return true" do
          cohort.send(:add_without_force, uid, hour).should be_true
        end
      end
    end

    describe "countint participants" do
      let(:aug22) { Date.new(2003,8,22) }
      let(:aug22_1pm) { Time.new(2003,8,22,13) }
      let(:aug22_11am) { Time.new(2003,8,22,11) }
      let(:aug22_9am) { Time.new(2003,8,22,9) }
      let(:aug23_3pm) { Time.new(2003,8,23,15) }
      let(:context1) { double :unique_identifier => '1' }
      let(:context2) { double :unique_identifier => '2' }
      let(:context3) { double :unique_identifier => '3' }
      let(:context4) { double :unique_identifier => '4' }

      before :each do
        cohort.add(context1, aug22_1pm)
        cohort.add(context2, aug22_1pm)
        cohort.add(context3, aug22_11am)
        cohort.add(context4, aug23_3pm)
      end

      describe "participants for hour" do
        it "should return the count for each hour" do
          cohort.participants_for_hour(aug22_1pm).should == 2
          cohort.participants_for_hour(aug22_11am).should == 1
          cohort.participants_for_hour(aug22_9am).should == 0
        end
      end

      describe "participants for hours" do
        it "should return the count for each hour" do
          cohort.participants_for_hours([aug22_9am, aug22_11am, aug22_1pm]).should == [0,1,2]
        end
      end
      describe "participants for day" do
        it "should sum the day" do
          cohort.participants_for_day(aug22).should == 3
        end
      end
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe FeatureRollout do
    let(:feature){ Blackbeard::Feature.create('example') }
    let(:context) { double }
    describe "rollout?" do
      it "should be true if active_visitor?" do
        feature.should_receive(:active_visitor?).with(context).and_return(true)
        feature.stub(:active_user?).with(context).and_return(false)
        feature.stub(:active_segment?).with(context).and_return(false)
        feature.rollout?(context).should be_true
      end

      it "should be true if active_user?" do
        feature.should_receive(:active_user?).with(context).and_return(true)
        feature.stub(:active_visitor?).with(context).and_return(false)
        feature.stub(:active_segment?).with(context).and_return(false)
        feature.rollout?(context).should be_true
      end

      it "should be true if active_segment?" do
        feature.should_receive(:active_segment?).with(context).and_return(true)
        feature.stub(:active_visitor?).with(context).and_return(false)
        feature.stub(:active_user?).with(context).and_return(false)
        feature.rollout?(context).should be_true
      end
    end

    describe "active_user?" do
      context "with no logged in user" do
        it "should be true if users_rate is 100" do
          feature.users_rate = 100
          context.stub(:user).and_return(nil)
          feature.active_user?(context).should be_false
        end
      end

      context "with logged in user" do
        it "should be false if users_rate is 0" do
          feature.users_rate = 0
          context.stub(:user).and_return(double :id => 0)
          feature.active_user?(context).should be_false
        end

        it "should be true if users_rate is 100" do
          feature.users_rate = 100
          context.stub(:user).and_return(double :id => 0)
          feature.active_user?(context).should be_true
        end

        describe "by user_id modulus" do
          [212,201,1,113,1008].each do |i|
            it "should be true" do
              feature.users_rate = 13
              context.stub(:user).and_return(double :id => i)
              context.stub(:user_id).and_return(i)
              feature.active_user?(context).should be_true
            end
          end

          [200,231,17,199,1018].each do |i|
            it "should be true" do
              feature.users_rate = 13
              context.stub(:user).and_return(double :id => i)
              context.stub(:user_id).and_return(i)
              feature.active_user?(context).should be_false
            end
          end
        end
      end
    end

    describe "active_visitor?" do
      it "should be false if rate is 0" do
        feature.visitors_rate = 0
        feature.active_visitor?(context).should be_false
      end
      it "should be true if rate is 100" do
        feature.visitors_rate = 100
        feature.active_visitor?(context).should be_true
      end

      describe "by visitor_id modulus" do
        [212,201,1,113,1008].each do |i|
          it "should be true" do
            feature.visitors_rate = 13
            context.stub(:visitor_id).and_return(i)
            feature.active_visitor?(context).should be_true
          end
        end

        [200,231,17,199,1018].each do |i|
          it "should be true" do
            feature.visitors_rate = 13
            context.stub(:visitor_id).and_return(i)
            feature.active_visitor?(context).should be_false
          end
        end
      end
    end

    describe "active_segment?" do
      it "should be false if there are no group segments" do
          feature.active_segment?(context).should be_false
      end
      context "with group segments" do
        before :each do
          @group_a = Group.create(:a)
          @group_b = Group.create(:b)
          feature.set_group_segments_for(:a, ["on"])
          feature.set_group_segments_for(:b, ["monkey", "chimp"])
          feature.save
          Group.stub(:find).with("a").and_return(@group_a)
          Group.stub(:find).with("b").and_return(@group_b)
        end

        it "should be false if user is in no group segments" do
          @group_a.should_receive(:segment_for).with(context).and_return(nil)
          @group_b.should_receive(:segment_for).with(context).and_return("babboon")
          feature.active_segment?(context).should be_false
        end

        it "should be true if user is in any group segment" do
          @group_a.stub(:segment_for).with(context).and_return(nil)
          @group_b.stub(:segment_for).with(context).and_return("monkey")
          feature.active_segment?(context).should be_true
        end

      end
    end

    describe "id_to_int" do
      it "should return an integer given an integer" do
        feature.id_to_int(20).should eq(20)
      end
      it "should return an integer given a string" do
        feature.id_to_int("happy").should be_a(Integer)
        feature.id_to_int("monday").should be_a(Integer)
      end
      it "should return a different int for each string (last 8 chars)" do
        feature.id_to_int("happy").should_not == feature.id_to_int("monday")
      end
    end

  end
end

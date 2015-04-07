require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe FeatureRollout do
    let(:feature){ Blackbeard::Feature.create('example') }
    let(:context) { double }
    describe "rollout?" do
      it "should be true if active_visitor?" do
        expect(feature).to receive(:active_visitor?).with(context).and_return(true)
        allow(feature).to receive(:active_user?).with(context).and_return(false)
        allow(feature).to receive(:active_segment?).with(context).and_return(false)
        expect(feature.rollout?(context)).to be_truthy
      end

      it "should be true if active_user?" do
        expect(feature).to receive(:active_user?).with(context).and_return(true)
        allow(feature).to receive(:active_visitor?).with(context).and_return(false)
        allow(feature).to receive(:active_segment?).with(context).and_return(false)
        expect(feature.rollout?(context)).to be_truthy
      end

      it "should be true if active_segment?" do
        expect(feature).to receive(:active_segment?).with(context).and_return(true)
        allow(feature).to receive(:active_visitor?).with(context).and_return(false)
        allow(feature).to receive(:active_user?).with(context).and_return(false)
        expect(feature.rollout?(context)).to be_truthy
      end
    end

    describe "active_user?" do
      context "with no logged in user" do
        it "should be false if users_rate is 100" do
          feature.users_rate = 100
          allow(context).to receive(:user).and_return(nil)
          expect(feature.active_user?(context)).to be_falsey
        end
      end

      context "with logged in user" do
        it "should be false if users_rate is 0" do
          feature.users_rate = 0
          allow(context).to receive(:user).and_return(double :id => 0)
          expect(feature.active_user?(context)).to be_falsey
        end

        it "should be true if users_rate is 100" do
          feature.users_rate = 100
          allow(context).to receive(:user).and_return(double :id => 0)
          expect(feature.active_user?(context)).to be_truthy
        end

        describe "by user_id modulus" do
          [212,201,1,113,1008].each do |i|
            it "should be true" do
              feature.users_rate = 13
              allow(context).to receive(:user).and_return(double :id => i)
              allow(context).to receive(:user_id).and_return(i)
              expect(feature.active_user?(context)).to be_truthy
            end
          end

          [200,231,17,199,1018].each do |i|
            it "should be true" do
              feature.users_rate = 13
              allow(context).to receive(:user).and_return(double :id => i)
              allow(context).to receive(:user_id).and_return(i)
              expect(feature.active_user?(context)).to be_falsey
            end
          end
        end
      end
    end

    describe "active_visitor?" do
      it "should be false if rate is 0" do
        feature.visitors_rate = 0
        expect(feature.active_visitor?(context)).to be_falsey
      end
      it "should be true if rate is 100" do
        feature.visitors_rate = 100
        expect(feature.active_visitor?(context)).to be_truthy
      end

      describe "by visitor_id modulus" do
        [212,201,1,113,1008].each do |i|
          it "should be true" do
            feature.visitors_rate = 13
            allow(context).to receive(:visitor_id).and_return(i)
            expect(feature.active_visitor?(context)).to be_truthy
          end
        end

        [200,231,17,199,1018].each do |i|
          it "should be true" do
            feature.visitors_rate = 13
            allow(context).to receive(:visitor_id).and_return(i)
            expect(feature.active_visitor?(context)).to be_falsey
          end
        end
      end
    end

    describe "active_segment?" do
      it "should be false if there are no group segments" do
        expect(feature.active_segment?(context)).to be_falsey
      end

      context "with group segments" do
        before :each do
          @group_a = Group.create(:a)
          @group_b = Group.create(:b)
          feature.set_group_segments_for(:a, ["on"])
          feature.set_group_segments_for(:b, ["monkey", "chimp"])
          feature.save
          allow(Group).to receive(:find).with("a").and_return(@group_a)
          allow(Group).to receive(:find).with("b").and_return(@group_b)
        end

        it "should be false if user is in no group segments" do
          expect(@group_a).to receive(:segment_for).with(context).and_return(nil)
          expect(@group_b).to receive(:segment_for).with(context).and_return("babboon")
          expect(feature.active_segment?(context)).to be_falsey
        end

        it "should be true if user is in any group segment" do
          allow(@group_a).to receive(:segment_for).with(context).and_return(nil)
          allow(@group_b).to receive(:segment_for).with(context).and_return("monkey")
          expect(feature.active_segment?(context)).to be_truthy
        end

      end
    end

    describe "id_to_int" do
      it "should return an integer given an integer" do
        expect(feature.id_to_int(20)).to eq(20)
      end
      it "should return an integer given a string" do
        expect(feature.id_to_int("happy")).to be_a(Integer)
        expect(feature.id_to_int("monday")).to be_a(Integer)
      end
      it "should return a different int for each string (last 8 chars)" do
        expect(feature.id_to_int("happy")).not_to eq(feature.id_to_int("monday"))
      end
    end

  end
end

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  class FakeContext < Struct.new(:user, :visitor)
    def user_id; user.id; end
    def visitor_id; visitor.id; end
  end

  describe FeatureRollout do
    let(:feature){ Blackbeard::Feature.create('example') }
    let(:context) { FakeContext.new }
    let(:threshold_moduli) { [92, 84, 34, 14, 20, 94, 81, 31, 67, 76,
                             74, 19, 38, 8, 5, 68, 30, 79, 80, 56,
                             70, 32, 16, 58, 7, 64, 33, 59, 86, 45,
                             61, 87, 53, 21, 1, 17, 75, 46, 29, 69,
                             55, 44, 10, 52, 26, 62, 54, 40, 90, 28,
                             18, 91, 51, 88, 77, 83, 57, 48, 35, 93,
                             60, 82, 23, 63, 41, 66, 4, 15, 9, 11,
                             97, 73, 22, 12, 24, 42, 13, 43, 96, 2,
                             6, 39, 3, 99, 72, 0, 47, 98, 49, 71,
                             50, 85, 65, 95, 37, 27, 25, 89, 78, 36] }


    describe "#rollout?" do
      it "should be true if active_visitor?" do
        expect(feature).to receive(:active_visitor?).with(context).and_return(true)
        allow(feature).to receive(:active_user?).with(context).and_return(false)
        allow(feature).to receive(:active_segment?).with(context).and_return(false)
        expect(feature.rollout?(context)).to eq(true)
      end

      it "should be true if active_user?" do
        expect(feature).to receive(:active_user?).with(context).and_return(true)
        allow(feature).to receive(:active_visitor?).with(context).and_return(false)
        allow(feature).to receive(:active_segment?).with(context).and_return(false)
        expect(feature.rollout?(context)).to eq(true)
      end

      it "should be true if active_segment?" do
        expect(feature).to receive(:active_segment?).with(context).and_return(true)
        allow(feature).to receive(:active_visitor?).with(context).and_return(false)
        allow(feature).to receive(:active_user?).with(context).and_return(false)
        expect(feature.rollout?(context)).to eq(true)
      end
    end


    describe "#active_user?" do
      context "with no logged in user" do
        it "should be false" do
          feature.users_rate = 100
          allow(context).to receive(:user).and_return(nil)
          expect(feature.active_user?(context)).to eq(false)
        end
      end

      context "with logged in user" do
        it "should be false if users_rate is 0" do
          feature.users_rate = 0
          allow(context).to receive(:user).and_return(double :id => 0)
          expect(feature.active_user?(context)).to eq(false)
        end

        it "should be true if users_rate is 100" do
          feature.users_rate = 100
          allow(context).to receive(:user).and_return(double :id => 0)
          expect(feature.active_user?(context)).to eq(true)
        end

        context "by user_id modulus" do
          before do
            feature.threshold_moduli = threshold_moduli
          end

          it "should be true for user_ids 202, 1403 and 104 for users_rate = 35" do
            # since 202 % 100 == 2, and the 2nd threshold value is 34,
            # then 34 < 35 means the feature should be active for user_id 202
            feature.users_rate = 35
            context.user = double(id: 202)
            expect(feature.active_user?(context)).to eq(true)

            context.user = double(id: 1403)
            expect(feature.active_user?(context)).to eq(true)

            context.user = double(id: 104)
            expect(feature.active_user?(context)).to eq(true)
          end

          it "should be false for user_ids 100, 2200 and 300 for users_rate = 50" do
            # since 2200 % 100 == 0, and the 0th value in threshold_moduli
            # is 92, which is not less than 50 (the users_rate)
            feature.users_rate = 50
            context.user = double(id: 100)
            expect(feature.active_user?(context)).to eq(false)

            context.user = double(id: 2200)
            expect(feature.active_user?(context)).to eq(false)

            context.user = double(id: 300)
            expect(feature.active_user?(context)).to eq(false)
          end
        end
      end
    end

    describe "#active_visitor?" do
      it "should be false if rate is 0" do
        feature.visitors_rate = 0
        expect(feature.active_visitor?(context)).to eq(false)
      end

      it "should be true if rate is 100" do
        feature.visitors_rate = 100
        expect(feature.active_visitor?(context)).to eq(true)
      end

      context "by visitor_id modulus" do
        before do
          feature.threshold_moduli = threshold_moduli
        end

        it "should be true for 299, 1096 and 2095 for visitors_rate = 50" do
          # since 299 % 100 == 99, and the 99th threshold value is 36,
          # then 36 < 50 means the feature should be active for visitor_id = 299
          feature.visitors_rate = 50
          context.visitor = double(id: 299)
          expect(feature.active_visitor?(context)).to eq(true)

          context.visitor = double(id: 1096)
          expect(feature.active_visitor?(context)).to eq(true)

          context.visitor = double(id: 2095)
          expect(feature.active_visitor?(context)).to eq(true)
        end

        it "should be false for 298, 1097 and 991 for visitors_rate = 50" do
          # since 298 % 100 == 98, and the 98th threshold value is 78,
          # then 78 > 50 means the feature should be inactive for visitor_id = 298
          feature.visitors_rate = 50
          context.visitor = double(id: 298)
          expect(feature.active_visitor?(context)).to eq(false)

          context.visitor = double(id: 1097)
          expect(feature.active_visitor?(context)).to eq(false)

          context.visitor = double(id: 991)
          expect(feature.active_visitor?(context)).to eq(false)
        end

      end
    end

    describe "#active_segment?" do
      it "should be false if there are no group segments" do
        expect(feature.active_segment?(context)).to eq(false)
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
          expect(feature.active_segment?(context)).to eq(false)
        end

        it "should be true if user is in any group segment" do
          allow(@group_a).to receive(:segment_for).with(context).and_return(nil)
          allow(@group_b).to receive(:segment_for).with(context).and_return("monkey")
          expect(feature.active_segment?(context)).to eq(true)
        end

      end
    end

    describe "#id_to_int" do
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

    ##########################################################################
    #              Testing statistical independence of features              #
    ##########################################################################
    #                                                                        #
    #   Given a feature X with a users_rate of 60 and a feature Y with a     #
    #   users_rate rate of 10, and a user U, the probability of U seeing     #
    #   feature X is 60%, and 10% for Y.                                     #
    #                                                                        #
    #   In notation: P(X) = 0.6                                              #
    #                P(Y) = 0.1                                              #
    #                                                                        #
    #   The property we are testing below is independence, which says that   #
    #   the probability of event X has no influence on the probability of    #
    #   event Y. In our example, the probability of seeing both X and Y is   #
    #   60% * 10%, which is 6%                                               #
    #                                                                        #
    #   In notation: P(X and Y)     = P(X)P(Y)         = 0.6*0.1 = 0.06      #
    #                P(X and not Y) = P(X)(1 - P(Y))   = 0.6*0.9 = 0.54      #
    #                P(not X and Y) = (1 - P(X))P(Y)   = 0.4*0.1 = 0.04      #
    #                P(not X nor Y) = (1-P(X))(1-P(Y)) = 0.4*0.9 = 0.36      #
    #                                                            + -----     #
    #                All possibilities should sum to 1.00 ----->   1.00      #
    ##########################################################################

    context "when there are two features (call them X and Y)" do
      let(:feature_x) { Blackbeard::Feature.create("X") }
      let(:feature_y) { Blackbeard::Feature.create("Y") }

      before(:all) do
        # Clear out stored attributes, so that you simulate the real random
        # nature of threshold_moduli arrays.
        db.del("features::y::attributes")
        db.del("features::x::attributes")
      end

      before(:each) do
        feature_x.users_rate = 60
        feature_y.users_rate = 10
      end

      context "and there are 10,000 users" do
        let(:contexts) { 10_000.times.map { |i| FakeContext.new(double(id: i)) } }
        let(:total) { contexts.count.to_f }
        let(:users_that_see_x) {
          contexts.select { |context| feature_x.active_user?(context) }
        }
        let(:users_that_see_y) {
          contexts.select { |context| feature_y.active_user?(context) }
        }
        let(:users_that_see_both) {
          contexts.select { |context|
            feature_x.active_user?(context) && feature_y.active_user?(context)
          }
        }
        let(:users_that_see_neither) {
          contexts.reject { |context|
            feature_x.active_user?(context) || feature_y.active_user?(context)
          }
        }
        let(:users_that_see_x_but_not_y) {
          contexts.select { |context|
            feature_x.active_user?(context) && !feature_y.active_user?(context)
          }
        }
        let(:users_that_see_y_but_not_x) {
          contexts.select { |context|
            !feature_x.active_user?(context) && feature_y.active_user?(context)
          }
        }
        let(:delta) { 0.075 }

        it "should show feature X to about 60% of users" do
          expect(users_that_see_x.count/total).to be_within(delta).of(0.60)
        end

        it "should show feature Y to about 10% of users" do
          expect(users_that_see_y.count/total).to be_within(delta).of(0.10)
        end

        it "should show both feature X and feature Y to about 6% of users" do
          expect(users_that_see_both.count/total).to be_within(delta).of(0.06)
        end

        it "should show feature X but not feature Y to about 54% of users" do
          expect(users_that_see_x_but_not_y.count/total).to be_within(delta).of(0.54)
        end

        it "should show feature Y but not feature X to about 4% of users" do
          expect(users_that_see_y_but_not_x.count/total).to be_within(delta).of(0.04)
        end

        it "should show neither feature X nor feature Y to 36% of users" do
          expect(users_that_see_neither.count/total).to be_within(delta).of(0.36)
        end

      end
    end

  end
end

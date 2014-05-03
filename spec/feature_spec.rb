require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe Feature do
    let(:feature){ Blackbeard::Feature.create('example') }

    describe "group_segments_for and set_group_segments_for" do
      it "should return an empty list if no segments" do
        feature.group_segments_for(:nothing).should == []
      end

      it "should return the segments for the group" do
        feature.set_group_segments_for(:hello, ["world", "goodbye"])
        feature.set_group_segments_for(:foo, "bar")
        feature.group_segments_for(:hello).should include("world","goodbye")
        feature.group_segments_for(:hello).should_not include("bar")
        feature.group_segments_for(:foo).should == ["bar"]
      end
    end

    describe "#active_for?" do
      let(:context){ double :unique_identifier => 'bob' }

      context "forgoing counting participation" do
        before :each do
          feature.should_not_receive(:record_participant)
        end

        context "when status is inactive" do
          it "should be false" do
            feature.status = :inactive
            feature.active_for?(context, false).should be_false
          end
        end

        context "when status is active" do
          it "should be true" do
            feature.status = :active
            feature.active_for?(context, false).should be_true
          end
        end

      end

      context "counting participation" do
        before :each do
          feature.should_receive(:record_participant).with(anything, context)
        end

        context "when status is nil" do
          it "should be false" do
            feature.active_for?(context).should be_false
          end
        end

        context "when status is inactive" do
          it "should be false" do
            feature.status = :inactive
            feature.active_for?(context).should be_false
          end
        end

        context "when status is active" do
          it "should be true" do
            feature.status = :active
            feature.active_for?(context).should be_true
          end
        end

        context "when status is 'rollout'" do
          it "should defer to rollout?" do
            rollout_result = double
            feature.status = :rollout
            feature.should_receive(:rollout?).with(context).and_return(rollout_result)
            feature.active_for?(context).should be(rollout_result)
          end
        end

      end
    end

    describe "segment_for" do
      let(:context){ double :unique_identifier => 'newbie' }

      describe "when user has not encountered feature" do
        it "should return nil" do
          feature.segment_for(context).should be_nil
        end
      end

      describe "when user saw active feature" do
        before :each do
          feature.active_participant_data.add(context.unique_identifier, Time.now)
        end
        it "should return active" do
          feature.segment_for(context).should == "active"
        end
      end

      describe "when user saw inactive feature" do
        before :each do
          feature.inactive_participant_data.add(context.unique_identifier, Time.now)
        end
        it "should return inactive" do
          feature.segment_for(context).should == "inactive"
        end
      end

    end


  end
end

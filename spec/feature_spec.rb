require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe Feature do
    let(:feature){ Blackbeard::Feature.create('example') }

    describe "group_segments_for and set_group_segments_for" do
      it "should return an empty list if no segments" do
        expect(feature.group_segments_for(:nothing)).to eq([])
      end

      it "should return the segments for the group" do
        feature.set_group_segments_for(:hello, ["world", "goodbye"])
        feature.set_group_segments_for(:foo, "bar")
        expect(feature.group_segments_for(:hello)).to include("world","goodbye")
        expect(feature.group_segments_for(:hello)).not_to include("bar")
        expect(feature.group_segments_for(:foo)).to eq(["bar"])
      end
    end

    describe "#active_for?" do
      let(:context){ double :unique_identifier => 'bob' }

      context "forgoing counting participation" do
        before :each do
          expect(feature).not_to receive(:record_participant)
        end

        context "when status is inactive" do
          it "should be false" do
            feature.status = :inactive
            expect(feature.active_for?(context, false)).to be_falsey
          end
        end

        context "when status is active" do
          it "should be true" do
            feature.status = :active
            expect(feature.active_for?(context, false)).to be_truthy
          end
        end

      end

      context "counting participation" do
        before :each do
          expect(feature).to receive(:record_participant).with(anything, context)
        end

        context "when status is nil" do
          it "should be false" do
            expect(feature.active_for?(context)).to be_falsey
          end
        end

        context "when status is inactive" do
          it "should be false" do
            feature.status = :inactive
            expect(feature.active_for?(context)).to be_falsey
          end
        end

        context "when status is active" do
          it "should be true" do
            feature.status = :active
            expect(feature.active_for?(context)).to be_truthy
          end
        end

        context "when status is 'rollout'" do
          it "should defer to rollout?" do
            rollout_result = double
            feature.status = :rollout
            expect(feature).to receive(:rollout?).with(context).and_return(rollout_result)
            expect(feature.active_for?(context)).to be(rollout_result)
          end
        end

      end
    end

    describe "segment_for" do
      let(:context){ double :unique_identifier => 'newbie' }

      describe "when user has not encountered feature" do
        it "should return nil" do
          expect(feature.segment_for(context)).to be_nil
        end
      end

      describe "when user saw active feature" do
        before :each do
          feature.active_participant_data.add(context.unique_identifier, Time.now)
        end
        it "should return active" do
          expect(feature.segment_for(context)).to eq("active")
        end
      end

      describe "when user saw inactive feature" do
        before :each do
          feature.inactive_participant_data.add(context.unique_identifier, Time.now)
        end
        it "should return inactive" do
          expect(feature.segment_for(context)).to eq("inactive")
        end
      end

    end


  end
end

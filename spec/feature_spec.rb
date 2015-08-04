require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe Feature do
    let(:feature){ Blackbeard::Feature.create('example') }

    describe ".find" do
      let(:feature) { Blackbeard::Feature.find('legacy-feature') }

      context "when feature's threshold_moduli is not empty" do
        it "should preserve the pre-existing value of threshold_moduli" do
          threshold_moduli = Blackbeard::Feature.create('example3').threshold_moduli
          feature = Blackbeard::Feature.find('example3')
          expect(feature.threshold_moduli).to eq(threshold_moduli)
        end
      end

      context "when feature's threshold_moduli is empty" do
        before do
          # to simulate a legacy feature, we can create a feature and set it's
          # threshold_moduli to nil
          legacy_feature = Blackbeard::Feature.create('legacy-feature')
          legacy_feature.threshold_moduli = []
          legacy_feature.save
        end

        it "should store a threshold_moduli value of (0..99) to preserve the existing behavior" do
          expect(feature.threshold_moduli).to eq((0..99).to_a)
        end
      end
    end

    describe ".create" do
      let(:feature){ Blackbeard::Feature.create('created-example') }

      it "creates a randomized threshold_moduli and stores it" do
        expect(feature.threshold_moduli).to_not eq((0..99).to_a)
      end
    end

    describe ".find_or_create" do
      it "calls .find" do
        expect(Blackbeard::Feature).to receive(:find).with("foobar")
        Blackbeard::Feature.find_or_create("foobar")
      end

      context "when feature is not found"
      it "calls .find" do
        allow(Blackbeard::Feature).to receive(:find).and_return(nil)
        expect(Blackbeard::Feature).to receive(:create).with("foobar")
        Blackbeard::Feature.find_or_create("foobar")
      end
    end

    describe "#threshold_moduli" do
      let(:feature) { Blackbeard::Feature.create("example2") }
      let!(:threshold_moduli) { feature.threshold_moduli }

      it "should have exactly 100 elements" do
        expect(feature.threshold_moduli.count).to eq(100)
      end

      it "has each number from 0 to 99 exactly once" do
        expect(feature.threshold_moduli.sort).to eq((0..99).to_a)
      end
    end

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
      let(:context) { double(unique_identifier: 'bob') }

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
      let(:context){ double(unique_identifier: 'newbie') }

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

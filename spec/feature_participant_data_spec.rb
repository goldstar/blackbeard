require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe "FeatureParticipantData" do
    let(:feature) { Feature.new(:example) }
    let(:hour) { Time.now }

    describe FeatureActiveParticipantData do
      let(:data) { FeatureActiveParticipantData.new(feature) }
      describe "#add" do
        it "should increment the participants for the hour" do
          expect{
            data.add('bob', hour)
          }.to change{ data.participants_for_hour(hour) }.by(1)
        end
        it "should set the value of the participant to active" do
          expect{
            data.add('bob', hour)
          }.to change{ data.value_for_participant('bob') }.from(nil).to("active")
        end
      end
    end

    describe FeatureInactiveParticipantData do
      let(:data) { FeatureInactiveParticipantData.new(feature) }
      describe "#add" do
        it "should increment the participants for the hour" do
          expect{
            data.add('bob', hour)
          }.to change{ data.participants_for_hour(hour) }.by(1)
        end
        it "should set the value of the participant to active" do
          expect{
            data.add('bob', hour)
          }.to change{ data.value_for_participant('bob') }.from(nil).to("inactive")
        end
      end
    end
  end
end

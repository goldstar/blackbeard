require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe "FeatureParticipantData" do
    let(:feature) { AppRevision.new('20170912') }
    let(:hour) { Time.now }

    describe AppRevisionNewerParticipantData do
      let(:data) { AppRevisionNewerParticipantData.new(feature) }

      describe "#add" do
        it "should increment the participants for the hour" do
          expect{
            data.add('bob', hour)
          }.to change{ data.participants_for_hour(hour) }.by(1)
        end
        it "should set the value of the participant to active" do
          expect{
            data.add('bob', hour)
          }.to change{ data.value_for_participant('bob') }.from(nil).to("newer")
        end
      end
    end

    describe AppRevisionOlderParticipantData do
      let(:data) { AppRevisionOlderParticipantData.new(feature) }
      describe "#add" do
        it "should increment the participants for the hour" do
          expect{
            data.add('bob', hour)
          }.to change{ data.participants_for_hour(hour) }.by(1)
        end
        it "should set the value of the participant to active" do
          expect{
            data.add('bob', hour)
          }.to change{ data.value_for_participant('bob') }.from(nil).to("older")
        end
      end
    end
  end
end

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

      describe '#destroy' do
        before do
          data.add('bob', hour)
        end

        it 'deletes hourly data' do
          expect {
            data.destroy
          }.to change {
            data.participants_for_hour(hour)
          }.from(1).to(0)
        end

        it 'deletes participant data' do
          expect {
            data.destroy
          }.to change {
            data.value_for_participant('bob')
          }.from('active').to(nil)
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

      describe '#destroy' do
        before do
          data.add('bob', hour)
        end

        it 'deletes hourly data' do
          expect {
            data.destroy
          }.to change {
            data.participants_for_hour(hour)
          }.from(1).to(0)
        end

        it 'deletes participant data' do
          expect {
            data.destroy
          }.to change {
            data.value_for_participant('bob')
          }.from('inactive').to(nil)
        end
      end
    end
  end
end

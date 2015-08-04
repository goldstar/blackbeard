require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe FeatureMetric do
    let(:metric) { Metric.create(:total, "one-total") }
    let(:feature) { Feature.create(:example) }
    let(:metric_data) { feature_metric.metric_data }
    let(:feature_metric){ FeatureMetric.new( feature, metric) }

    describe "#add" do
      let(:context) { double(:unique_identifier => 'uid', :controller => double, :user => double) }

      it "should increment metric data" do
        allow(feature).to receive(:segment_for).and_return("segment")
        expect(metric_data).to receive(:add).with("uid",1, "segment")
        feature_metric.add(context, 1)
      end

      it "should not increment nil segments" do
        allow(feature).to receive(:segment_for).and_return(nil)
        expect(metric_data).not_to receive(:add).with("uid",1, "segment")
        feature_metric.add(context, 1)
      end
    end

  end
end

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe CohortMetric do
    let(:metric) { Metric.create(:total, "one-total") }
    let(:cohort) { Cohort.create(:example) }
    let(:cohort_metric){ CohortMetric.new( cohort, metric) }
    let(:metric_data) { cohort_metric.metric_data }

    describe "add" do
      let(:context) { double(:unique_identifier => 'uid', :controller => double, :user => double) }

      it "should increment metric data" do
        cohort.should_receive(:hour_id_for_participant).with('uid').and_return("2014010101")
        metric_data.should_receive(:add_at).with("2014010101","uid",1)
        cohort_metric.add(context, 1)
      end

      it "should not increment non participants" do
        cohort.should_receive(:hour_id_for_participant).with('uid').and_return(nil)
        metric_data.should_not_receive(:add_at).with("2014010101","uid",1)
        cohort_metric.add(context, 1)
      end
    end
  end
end

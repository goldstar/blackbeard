require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Blackbeard
  module MetricData

    describe UidGenerator do
      let(:metric) { Blackbeard::Metric.new(:total, "one-total") }
      let(:metric2) { Blackbeard::Metric.new(:total, "two-total") }
      let(:metric_data) { metric.metric_data }
      let(:metric_data2) { metric2.metric_data }

      context "already existing uid" do
        it "should return the existing uid" do
          UidGenerator.new(metric_data).uid.should == UidGenerator.new(metric_data).uid
        end
      end
      context "new metric_data" do
        it "should increment to the next uid" do
          uid = UidGenerator.new(metric_data).uid
          UidGenerator.new(metric_data2).uid.to_i.should == uid.to_i + 1
        end
      end

      describe "lookup field" do
        context "with a cohort" do
          it "should return the field unique to cohort" do
            metric.save
            cohort = Cohort.create(:example_cohort)
            cohort_metric = CohortMetric.new(cohort, metric)
            metric.add_cohort(cohort)
            gen1 = UidGenerator.new(cohort_metric.metric_data)
            gen2 = UidGenerator.new(metric.metric_data)
            gen1.send(:lookup_field).should_not == gen2.send(:lookup_field)
          end
        end
      end
    end

  end
end

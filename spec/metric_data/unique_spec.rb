require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Blackbeard
  module MetricData
    describe Unique do

      let(:metric) { Blackbeard::Metric.create(:unique, "join") }
      let(:metric_data) { metric.metric_data }
      let(:uid) { "unique identifier" }
      let(:ouid) { "other unique identifier" }

      describe "add" do
        it "should increment the metric for the uid" do
          expect{
            metric_data.add(uid)
          }.to change{ metric_data.result_for_hour(tz.now)["uniques"] }.from(nil).to(1)
        end

        it "should not increment the metric for duplicate uids" do
          metric_data.add(uid)
          expect{
            metric_data.add(uid)
          }.to_not change{ metric_data.result_for_hour(tz.now) }
        end

        context "with segment" do
          it "should increment the segment" do
            expect{
              metric_data.add(uid, 1, "segment")
            }.to change{ metric_data.result_for_hour(tz.now)["segment"] }
          end

          it "should not increment the global" do
            expect{
              metric_data.add(uid, 1, "segment")
            }.to_not change{ metric_data.result_for_hour(tz.now)["uniques"] }
          end
        end

      end

      describe "result_for_hour" do
        it "should empty if no metric has been recorded" do
          expect(metric_data.result_for_hour(tz.now)).to be_empty
        end

        it "should return 1 if metric called once" do
          metric_data.add(uid)
          expect(metric_data.result_for_hour(tz.now)).to eq({"uniques" => 1})
        end

        it "should return 1 if metric called more than once" do
          3.times{ metric_data.add(uid) }
          expect(metric_data.result_for_hour(tz.now)).to eq({"uniques" => 1})
        end

        it "should return 2 if metric was called with 2 uniques" do
          metric_data.add(uid)
          metric_data.add(ouid)
          expect(metric_data.result_for_hour(tz.now)).to eq({"uniques" => 2})
        end

      end

      describe "generate_result_for_day" do
        let(:date) { Date.new(2014,1,1) }
        before :each do
          at_1am = Time.new(2014,1,1,1)
          metric_data.add_at(at_1am, '1' )
          metric_data.add_at(at_1am, '2' )
          at_2pm = Time.new(2014,1,1,14)
          metric_data.add_at(at_2pm, '2' )
          metric_data.add_at(at_2pm, '3' )
          metric_data.add_at(at_2pm, '4' )
        end

        it "should sum the hours" do
          expect(metric_data.send(:generate_result_for_day, date)).to eq({"uniques" => 4})
        end

        it "should store the result if it's not today's result" do
          day_key = metric_data.send(:key_for_date, date)
          expect(db).to receive(:hash_multi_set).with(day_key, {"uniques" => 4})
          metric_data.send(:generate_result_for_day, date)
        end

      end
    end
  end

end

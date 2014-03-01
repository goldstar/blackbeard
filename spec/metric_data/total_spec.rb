require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Blackbeard
  module MetricData

    describe Total do

      let(:metric) { Blackbeard::Metric.create(:total, "page views") }
      let(:metric_data) { metric.metric_data }
      let(:uid) { "unique identifier" }
      let(:ouid) { "other unique identifier" }

      describe "add" do
        it "should increment the metric by the amount" do
          expect{
            metric_data.add(uid, 2)
          }.to change{ metric_data.result_for_hour(tz.now)["total"] }.from(nil).to(2)
        end

        it "should increment an existing amount" do
          metric_data.add(uid, 1)
          expect{
            metric_data.add(uid, 2)
          }.to change{ metric_data.result_for_hour(tz.now)["total"] }.from(1).to(3)
        end

        it "should handle negatives ok" do
          metric_data.add(uid, 2)
          expect{
            metric_data.add(uid, -1)
          }.to change{ metric_data.result_for_hour(tz.now)["total"] }.from(2).to(1)
        end

        it "should handle floats" do
          metric_data.add(uid, 2.5)
          expect{
            metric_data.add(uid, 1.25)
          }.to change{ metric_data.result_for_hour(tz.now)["total"] }.to(3.75)
        end

        context "with segment" do
          it "should increment the segment" do
            expect{
              metric_data.add(uid, 1, "segment")
            }.to change{ metric_data.result_for_hour(tz.now)["segment"] }.from(nil).to(1)
          end
        end


      end



      describe "result_for_hour" do
        it "should return 0 if no metric has been recorded" do
          metric_data.result_for_hour(tz.now).should be_empty
        end

        it "should return sum if metric called more than once" do
          metric_data.add(uid, 2)
          metric_data.add(uid, 4)
          metric_data.result_for_hour(tz.now).should == {"total"=>6.0}
        end
      end

      describe "result_for_day" do
        let(:date) { Date.new(2014,1,1) }
        context "result in db" do
          before :each do
            day_key = metric_data.send(:key_for_date, date)
            db.hash_set(day_key, "total", 4)
          end
          it "should return the result from db" do
            metric_data.result_for_day(date).should == {"total"=>4.0}
          end
          it "should not remerge the results" do
            metric_data.should_not_receive(:generate_result_for_day).with(date)
            metric_data.result_for_day(date)
          end
        end

        context "result not in db" do
          it "should merge hours" do
            metric_data.should_receive(:generate_result_for_day).with(date).and_return({"total" => "2"})
            metric_data.result_for_day(date).should == {"total" => 2.0 }
          end
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
          metric_data.send(:generate_result_for_day, date).should == {"total" => 5.0}
        end

        it "should store the result if it's not today's result" do
          day_key = metric_data.send(:key_for_date, date)
          db.should_receive(:hash_multi_set).with(day_key, {"total" => 5})
          metric_data.send(:generate_result_for_day, date)
        end

      end
    end
  end
end

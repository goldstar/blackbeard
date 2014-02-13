require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module Blackbeard
  module MetricData
    describe Total do

      let(:metric) { Blackbeard::Metric.new(:total, "page views") }
      let(:metric_data) { metric.metric_data }
      let(:db) { metric.send(:db) }
      let(:uid) { "unique identifier" }
      let(:ouid) { "other unique identifier" }

      describe "add" do
        it "should increment the metric by the amount" do
          expect{
            metric_data.add(uid, 2)
          }.to change{ metric_data.result_for_hour(Blackbeard.tz.now) }.by(2)
        end

        it "should increment an existing amount" do
          metric_data.add(uid, 1)
          expect{
            metric_data.add(uid, 2)
          }.to change{ metric_data.result_for_hour(Blackbeard.tz.now) }.from(1).to(3)
        end

        it "should handle negatives ok" do
          metric_data.add(uid, 2)
          expect{
            metric_data.add(uid, -1)
          }.to change{ metric_data.result_for_hour(Blackbeard.tz.now) }.from(2).to(1)
        end

        it "should handle floats" do
          metric_data.add(uid, 2.5)
          expect{
            metric_data.add(uid, 1.25)
          }.to change{ metric_data.result_for_hour(Blackbeard.tz.now) }.to(3.75)
        end
      end



      describe "result_for_hour" do
        it "should return 0 if no metric has been recorded" do
          metric_data.result_for_hour(Blackbeard.tz.now).should be_zero
        end

        it "should return sum if metric called more than once" do
          metric_data.add(uid, 2)
          metric_data.add(uid, 4)
          metric_data.result_for_hour(Blackbeard.tz.now).should == 6
        end
      end

      describe "result_for_day" do
        let(:date) { Date.new(2014,1,1) }
        context "result in db" do
          before :each do
            day_key = metric_data.send(:key_for_date, date)
            db.set(day_key, 4)
          end
          it "should return the result from db" do
            metric_data.result_for_day(date).should == 4.0
          end
          it "should not remerge the results" do
            metric_data.should_not_receive(:generate_result_for_day).with(date)
            metric_data.result_for_day(date)
          end
        end

        context "result in not in db" do
          it "should merge hours" do
            metric_data.should_receive(:generate_result_for_day).with(date).and_return(2.0)
            metric_data.result_for_day(date).should == 2.0
          end
        end
      end


      describe "generate_result_for_day" do
        let(:date) { Date.new(2014,1,1) }
        before :each do
          key_for_1am = metric_data.send(:key_for_hour, Time.new(2014,1,1,1))
          db.set(key_for_1am, 2)
          key_for_2pm = metric_data.send(:key_for_hour, Time.new(2014,1,1,14))
          db.set(key_for_2pm, 3)
        end

        it "should sum the hours" do
          metric_data.send(:generate_result_for_day, date).should == 5.0
        end

        it "should store the result if it's not today's result" do
          day_key = metric_data.send(:key_for_date, date)
          db.should_receive(:set).with(day_key, 5.0)
          metric_data.send(:generate_result_for_day, date)
        end

      end
    end
  end
end

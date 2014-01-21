require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Context do
  let(:pirate) { Blackbeard::Pirate.new }
  let(:context) { Blackbeard::Context.new(pirate, :user_id => 9) }
  let(:uid) { context.unique_identifier }
  let(:total_metric) { Blackbeard::Metric::Total.new(:total_things) }
  let(:unique_metric) { Blackbeard::Metric::Unique.new(:unique_things) }

  describe "#add_total" do
    it "should call add on the total metric" do
      pirate.should_receive(:total_metric).with(total_metric.name){ total_metric }
      total_metric.should_receive(:add).with(uid, 3)
      context.add_total( total_metric.name, 3 )
    end
  end

  describe "#add_unique" do
    it "should call add on the unique metric" do
      pirate.should_receive(:unique_metric).with(unique_metric.name){ unique_metric }
      unique_metric.should_receive(:add).with(uid)
      context.add_unique( unique_metric.name )
    end
  end

end

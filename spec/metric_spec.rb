require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Metric do
  describe "self.all" do
    before :each do
      Blackbeard::Metric::Total.new("one-total")
      Blackbeard::Metric::Total.new("two-total")
      Blackbeard::Metric::Unique.new("one-unique")
    end
    it "should return a Metric Object for each Metric created" do
      Blackbeard::Metric.all.should have(3).metrics
    end

    it "should instantiate each metric with the correct class" do
      Blackbeard::Metric.all.select{|m| m.name == "two-total"}.should have(1).metric
      Blackbeard::Metric.all.select{|m| m.name == "two-total"}.first.should be_a(Blackbeard::Metric::Total)
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Pirate do
  let(:pirate) { Blackbeard::Pirate.new }

  describe "memoization" do
    let(:name){ "bond" }

    it "should get metrics once" do
      Blackbeard::Metric.should_receive(:find_or_create).with(:total, name).once.and_return(double)
      4.times{ pirate.metric(:total, name) }
    end

    it "should get test once" do
      Blackbeard::Test.should_receive(:find_or_create).with(name).once.and_return(double)
      4.times{ pirate.test(name) }
    end

    it "should get features once" do
      Blackbeard::Feature.should_receive(:find_or_create).with(name).once.and_return(double)
      4.times{ pirate.feature(name) }
    end

    it "should get cohorts once" do
      Blackbeard::Cohort.should_receive(:find_or_create).with(name).once.and_return(double)
      4.times{ pirate.cohort(name) }
    end

  end

  describe "#context" do
    it "should return a brand new context" do
      new_context = double
      Blackbeard::Context.should_receive(:new).and_return(new_context)
      pirate.context.should == new_context
    end
  end

  describe "set context delegations" do
    context "with no set context" do
      it "add_unique should not raise error" do
        expect{ pirate.add_unique(:example) }.to_not raise_error
      end

      it "add_total should not raise error" do
        expect{ pirate.add_total(:example, 1) }.to_not raise_error
      end

      it "ab_test should not raise error" do
        expect{ pirate.ab_test(:example, :on => 1, :off => 2) }.to_not raise_error
      end

      it "feature_active? should not raise error" do
        expect{ pirate.feature_active?(:example) }.to_not raise_error
      end

      it "add_to_cohort should not raise error" do
        expect{ pirate.add_to_cohort(:example) }.to_not raise_error
      end

    end
    context "with context set" do
      let(:user){ double }
      let!(:set_context){ pirate.set_context(user) }

      it "should delegate #add_unique" do
        set_context.should_receive(:add_unique).with(:example_metric).and_return(set_context)
        pirate.add_unique(:example_metric)
      end

      it "should delegate #add_total" do
        set_context.should_receive(:add_total).with(:example_metric, 1).and_return(set_context)
        pirate.add_total(:example_metric, 1)
      end

      it "should delegate #ab_test" do
        set_context.should_receive(:ab_test).with(:example_test, :on => 1, :off => 2).and_return(set_context)
        pirate.ab_test(:example_test, :on => 1, :off => 2)
      end

      it "should delegate #feature_active?" do
        set_context.should_receive(:feature_active?).with(:example_feature).and_return(false)
        pirate.feature_active?(:example_feature)
      end

      it "should delegate add_to_cohort" do
        timestamp = double
        set_context.should_receive(:add_to_cohort).with(:example, timestamp).and_return(true)
        pirate.add_to_cohort(:example, timestamp)
      end

      it "should delegate add_to_cohort!" do
        timestamp = double
        set_context.should_receive(:add_to_cohort!).with(:example, timestamp).and_return(true)
        pirate.add_to_cohort!(:example, timestamp)
      end
    end
  end

end

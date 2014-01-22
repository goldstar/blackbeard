require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Pirate do
  let(:pirate) { Blackbeard::Pirate.new }

  describe "memoization" do
    let(:name){ "bond" }

    it "should get features once" do
      Blackbeard::Feature.should_receive(:new).with(name).once.and_return(true)
      4.times{ pirate.feature(name) }
    end

    it "should get unique metrics once" do
      Blackbeard::Metric::Unique.should_receive(:new).with(name).once.and_return(true)
      4.times{ pirate.unique_metric(name) }
    end

    it "should get total metrics once" do
      Blackbeard::Metric::Total.should_receive(:new).with(name).once.and_return(true)
      4.times{ pirate.total_metric(name) }
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
      it "should raise Blackbeard::MissingContextError" do
        expect{ pirate.add_unique(:exmaple) }.to raise_error( Blackbeard::MissingContextError )
      end
      it "should raise Blackbeard::MissingContextError" do
        expect{ pirate.add_total(:exmaple, 1) }.to raise_error( Blackbeard::MissingContextError )
      end
    end
    context "with context set" do
      let!(:set_context){ pirate.set_context(:user_id => 1) }

      it "should delegate #add_unique" do
        set_context.should_receive(:add_unique).with(:example_metric).and_return(set_context)
        pirate.add_unique(:example_metric)
      end

      it "should delegate #add_total" do
        set_context.should_receive(:add_total).with(:example_metric, 1).and_return(set_context)
        pirate.add_total(:example_metric, 1)
      end
    end
  end

end

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Context do
  let(:pirate) { Blackbeard::Pirate.new }
  let(:context) { Blackbeard::Context.new(pirate, :user_id => 9) }
  let(:uid) { context.unique_identifier }
  let(:total_metric) { Blackbeard::Metric::Total.new(:total_things) }
  let(:unique_metric) { Blackbeard::Metric::Unique.new(:unique_things) }
  let(:test) { Blackbeard::Test.new(:example_test) }

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

  describe "#ab_test" do
    before :each do
      pirate.should_receive(:test).with(test.name).and_return(test)
    end

    it "should call select_variation on the test" do
      test.should_receive(:add_variations).with([:on, :off]).and_return(test)
      test.should_receive(:select_variation).and_return(:off)
      context.ab_test(:example_test, :on => 1, :off => 2)
    end

    context "when passed options" do
      before :each do
        test.should_receive(:select_variation).and_return('double')
      end

      it "should return the value of selected option" do
        context.ab_test(:example_test, :on => 1, :off => 2, :double => 'trouble').should == 'trouble'
      end

      it "should return nil when the selected variation is not an option" do
        context.ab_test(:example_test, :on => 1, :off => 2).should be_nil
      end
    end

    context "when not passed options" do
      before :each do
        test.should_receive(:select_variation).and_return('double')
      end

      it "should return a select_variation obj equal to the selected variation" do
        test_result = context.ab_test(:example_test)
        test_result.should be_a(Blackbeard::SelectedVariation)
        test_result.should == :double
      end
    end

  end

  describe "#active?" do
    let(:inactive_test) { Blackbeard::Test.new(:inactive_test) }
    let(:active_test) { Blackbeard::Test.new(:active_test) }

    before :each do
      pirate.stub(:test).with(active_test.name).and_return(active_test)
      pirate.stub(:test).with(inactive_test.name).and_return(inactive_test)
    end

    it "should return true when active" do
      active_test.should_receive(:select_variation).and_return('active')
      context.active?(:active_test).should be_true
    end

    it "should return true when active" do
      inactive_test.should_receive(:select_variation).and_return('inactive')
      context.active?(:inactive_test).should be_false
    end

  end

end

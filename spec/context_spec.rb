require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe Context do
    let(:pirate) { Pirate.new }
    let(:user) { double(:id => 1) }
    let(:context) { Context.new(pirate, user) }
    let(:uid) { context.unique_identifier }
    let(:total_metric) { Metric.create(:total, :things) }
    let(:unique_metric) { Metric.create(:unique, :things) }
    let(:test) { Test.create(:example_test) }

    describe "#add_total" do
      it "should call add on the total metric" do
        pirate.should_receive(:metric).with(:total, total_metric.id){ total_metric }
        total_metric.should_receive(:add).with(context, 3)
        context.add_total( total_metric.id, 3 )
      end
    end

    describe "#add_unique" do
      it "should call add on the unique metric" do
        pirate.should_receive(:metric).with(:unique, unique_metric.id){ unique_metric }
        unique_metric.should_receive(:add).with(context, 1)
        context.add_unique( unique_metric.id )
      end
    end

    describe "#ab_test" do
      before :each do
        pirate.should_receive(:test).with(test.id).and_return(test)
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

    describe "unique_identifier" do
      it "should work with users" do
        Context.new(pirate, user, nil).unique_identifier.should == "a1"
      end
      it "should work without users" do
        request = double(:cookies => {})
        controller = double(:request => request)
        Context.new(pirate, nil, controller).unique_identifier.should == "b1"
      end
    end

    describe "#feature_active?" do
      let(:inactive_feature) { Blackbeard::Feature.create(:inactive_feature) }
      let(:active_feature) { Blackbeard::Feature.create(:active_feature) }

      before :each do
        pirate.stub(:feature).with(active_feature.id).and_return(active_feature)
        pirate.stub(:feature).with(inactive_feature.id).and_return(inactive_feature)
      end

      it "should return true when active" do
        active_feature.should_receive(:active?).and_return(true)
        context.feature_active?(:active_feature).should be_true
      end

      it "should return true when active" do
        inactive_feature.should_receive(:active?).and_return(false)
        context.feature_active?(:inactive_feature).should be_false
      end

    end

  end
end

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
    let(:cohort) { Cohort.create(:joined) }

    describe "#add_total" do
      it "should call add on the total metric" do
        expect(pirate).to receive(:metric).with(:total, total_metric.id){ total_metric }
        expect(total_metric).to receive(:add).with(context, 3)
        context.add_total( total_metric.id, 3 )
      end
    end

    describe "#add_unique" do
      it "should call add on the unique metric" do
        expect(pirate).to receive(:metric).with(:unique, unique_metric.id){ unique_metric }
        expect(unique_metric).to receive(:add).with(context, 1)
        context.add_unique( unique_metric.id )
      end
    end

    describe "#add_to_cohort" do
      it "should call add on the cohort" do
        expect(pirate).to receive(:cohort).with("joined"){ cohort }
        expect(cohort).to receive(:add).with(context, nil, false)
        context.add_to_cohort(:joined)
      end
    end

    describe "#ab_test" do
      before :each do
        expect(pirate).to receive(:test).with(test.id).and_return(test)
      end

      it "should call select_variation on the test" do
        expect(test).to receive(:add_variations).with([:on, :off]).and_return(test)
        expect(test).to receive(:select_variation).and_return(:off)
        context.ab_test(:example_test, :on => 1, :off => 2)
      end

      context "when passed options" do
        before :each do
          expect(test).to receive(:select_variation).and_return('double')
        end

        it "should return the value of selected option" do
          expect(context.ab_test(:example_test, :on => 1, :off => 2, :double => 'trouble')).to eq('trouble')
        end

        it "should return nil when the selected variation is not an option" do
          expect(context.ab_test(:example_test, :on => 1, :off => 2)).to be_nil
        end
      end

      context "when not passed options" do
        before :each do
          expect(test).to receive(:select_variation).and_return('double')
        end

        it "should return a select_variation obj equal to the selected variation" do
          test_result = context.ab_test(:example_test)
          expect(test_result).to be_a(Blackbeard::SelectedVariation)
          expect(test_result).to eq(:double)
        end
      end

    end

    describe "unique_identifier" do
      it "should work with users" do
        expect(Context.new(pirate, user, nil).unique_identifier).to eq("a1")
      end
      it "should work without users" do
        request = double(:cookies => {})
        controller = double(:request => request)
        expect(Context.new(pirate, nil, controller).unique_identifier).to eq("b1")
      end
    end

    describe "#feature_active?" do
      let(:inactive_feature) { Blackbeard::Feature.create(:inactive_feature) }
      let(:active_feature) { Blackbeard::Feature.create(:active_feature) }

      before :each do
        allow(pirate).to receive(:feature).with(active_feature.id).and_return(active_feature)
        allow(pirate).to receive(:feature).with(inactive_feature.id).and_return(inactive_feature)
      end

      it "should return true when active" do
        expect(active_feature).to receive(:active_for?).with(context, true).and_return(true)
        expect(context.feature_active?(:active_feature)).to be_truthy
      end

      it "should return true when active" do
        expect(inactive_feature).to receive(:active_for?).with(context, true).and_return(false)
        expect(context.feature_active?(:inactive_feature)).to be_falsey
      end
    end

  end
end

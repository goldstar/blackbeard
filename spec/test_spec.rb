require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Test do
  let(:test){ Blackbeard::Test.new('example') }

  describe "#add_variations" do
    before :each do
      test.add_variations('hello', 'goodbye')
    end

    context "when they all already exist" do
      it "should not add any" do
        db.should_not_receive(:set_add_members)
        test.add_variations('hello', 'goodbye')
      end
    end

    it "should only add new ones" do
      db.should_receive(:set_add_members).with(test.send(:variations_set_key), ['world'])
      test.add_variations('goodbye', 'world')
    end

    it "should break the variations memoization so they are immediately found" do
      test.add_variations('goodbye', 'world')
      test.variations.should include('hello','goodbye','world')
    end

  end

  describe "#variations" do
    it "should return the existing variations" do
      test.add_variations('hello', 'goodbye')
      test.variations.should include('hello','goodbye')
    end
    it "should memoize the result" do
      db.should_receive(:set_members).with(test.send(:variations_set_key)).and_return(['hello','goodbye'])
      test.variations.should include('hello','goodbye')
      db.should_not_receive(:set_members)
      test.variations.should include('hello','goodbye')
    end
  end

  describe "#select_variation" do
    # '*' - experimenting
    # :variation

    context "feature is static variation" do
      it "should return the static variation"
    end

    context "experimenting" do
      context "unique_identifier has already seen the variation" do
        it "should return the same variation"
      end

      context "unique_identifier has not already seen the variation" do
        it "should employ a strategy to select a variation"
      end
    end

  end
end

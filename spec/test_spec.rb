require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Test do
  let(:test){ Blackbeard::Test.create('example') }

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

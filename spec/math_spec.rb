require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# file:docs/beta.org explains this function in more detail
RSpec.describe Blackbeard::Math do
  describe "#beta" do
    context "when x = 2 and y = 3" do
      let(:x) { 2 }
      let(:y) { 3 }
      subject { described_class.beta(x, y) }
      it { is_expected.to be_within(0.001).of(0.0833) }
    end

    context "when x = 200 and y = 100" do
      let(:x) { 200 }
      let(:y) { 100 }
      subject { described_class.beta(x, y) }
      it { is_expected.to be_within(1e-84).of(3.60729e-84) }
    end

    context "when x = 1000 and y = 1000" do
      let(:x) { 1000 }
      let(:y) { 1000 }
      subject { described_class.beta(x, y) }
      it { is_expected.to be_within(1e-604).of(9.764902e-604) }
    end

  end


end

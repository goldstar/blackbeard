require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

# file:docs/beta.org explains this function in more detail
RSpec.describe Blackbeard::Math do
  describe "#beta" do
    subject { described_class.beta(x, y) }
    context "when x = 2 and y = 3" do
      let(:x) { 2 }
      let(:y) { 3 }
      it { is_expected.to be_within(0.001).of(0.0833) }
    end

    context "when x = 200 and y = 100" do
      let(:x) { 200 }
      let(:y) { 100 }
      let(:delta) { 1e-84 }
      it { is_expected.to be_within(delta).of(3.60729e-84) }
    end

    context "when x = 1000 and y = 1000" do
      let(:x) { 1000 }
      let(:y) { 1000 }
      let(:delta) { BigDecimal.new("1e-604") }
      it { is_expected.to be_within(delta).of(BigDecimal.new("9.764902e-604")) }
    end

    context "when x = 10,000 and y = 1" do
      let(:x) { 10_000 }
      let(:y) { 1 }
      let(:delta) { 0.0001 }
      it { is_expected.to be_within(delta).of(BigDecimal.new("9.782834964902e-604")) }
    end
  end


end

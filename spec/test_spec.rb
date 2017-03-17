require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Test do
  let(:user) { double(id: 2) }
  let(:pirate) { Blackbeard::Pirate.new }
  before do
    test.add_variations('one', 'two')
  end
  let(:test){ pirate.test('example') }

  describe ".create" do
    it "creates a index_moduli array to make tests independent of each other" do
      expect(test.index_moduli.sort).to eq((0..99).to_a)
    end
  end

  context "probability of A or B" do

    # Assuming only two variations A and B, the test rate is the rate for A,
    # and B is 100% - a_rate
    describe "#a_rate" do
      subject { test.a_rate }
      it { is_expected.to eq(50) }
    end

    describe "#b_rate" do
      subject { test.b_rate }

      it { is_expected.to eq(50) }

      context "when a_rate is 25%" do
        let(:test){ pirate.test('example2') }
        before do
          test.a_rate = 25
        end

        it { is_expected.to eq(75) }
      end

    end

    it "has a_rate + b_rate = 100" do
      expect(test.a_rate + test.b_rate).to eq(100)
    end

  end

  # aNUM is the unique id for a user
  # bNUM is for a visitor
  # Since a and b are both hex digits, it is fast and convenient to interpret
  # this as an integer in hexadecimal for the purposes of indexing into the
  describe "#index_from_unique_id" do
    let(:unique_identifier) { "a206" }

    it "equals  "
  end

  describe "#select_variation" do

    context "when feature is static variation" do
      it "should return the static variation" do
        expect(test.select_variation).to eq(:off)
      end
    end

    context "when experimenting" do
      let(:uniq_id) { "b20877" }

      context "unique_identifier has already seen the variation" do
        it "should return the same variation" do
          variation = test.select_variation(uniq_id)
          expect(test.select_variation(uniq_id)).to eq(variation)
        end

        it "doesn't increase the number of participants" do
          test.select_variation(uniq_id)
          expect{
            test.select_variation(uniq_id)
          }.to_not change(test, :participant_count)
        end

        it "counts each participant once" do
          3.times { test.select_variation("a1") }
          test.select_variation("a2")
          test.select_variation("a3")

          expect(test.participants).to eq(%W(a1 a2 a3))
        end

      end


      context "unique_identifier has not already seen the variation" do
        it "uses the unique identifier a2934 or b2093 as a hex integer and mods it by 100" do
          index = test.index_moduli[uniq_id.to_i(16) % 100] % 2
          expected_variation = test.ab_variations[index].to_sym
          expect(test.select_variation(uniq_id)).to eq(expected_variation)
        end

      end
    end

  end
end


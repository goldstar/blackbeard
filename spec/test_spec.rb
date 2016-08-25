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


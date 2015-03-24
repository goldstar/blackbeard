require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe Change do
    let(:hash) { {:foo => 'bar'} }

    describe "log" do
      it "should return a change object" do
        expect(Change.log(hash)).to be_a(Change)
      end
    end

    describe "find" do
      let(:id) { Change.log(hash).id }
      it "should return a change object" do
        expect(Change.find(id)).to be_a(Change)
      end

      it "should be the hash" do
        expect(Change.find(id)[:foo]).to eq('bar')
      end
    end

    describe "finders" do
      before :each do
        @id_1 = Change.log(hash).id
        @id_2 = Change.log(hash).id
        @id_3 = Change.log(hash).id
      end

      describe "find_all" do
        it "should return each found" do
          expect(Change.find_all(@id_2, @id_1, 0, @id_3).map{|c| c.id}).to eq([@id_2, @id_1, @id_3])
        end
        it "should return an empty array when none found" do
          expect(Change.find_all('nothng')).to eq([])
        end
      end

      describe "last" do
        it "should the last(x) newest to oldest" do
          expect(Change.last(2).map{|c| c.id}).to eq([@id_3, @id_2])
        end
      end
    end
  end
end

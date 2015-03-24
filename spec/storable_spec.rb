require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe Storable do
    class ExampleStorable < Storable
      set_master_key :example
      string_attributes :name
    end

    class AnotherStorable < Storable
      set_master_key :another
    end

    describe "initialize" do
      it "should be able to instantiate" do
        expect{
          ExampleStorable.new(:some_id)
        }.to_not raise_error
      end

      it "should not save" do
        expect{
          ExampleStorable.new(:some_id)
        }.to_not change{ ExampleStorable.count }
      end
    end

    describe "self.find" do
      it "should find an existing record" do
        example = ExampleStorable.create(:some_id)
        ExampleStorable.find(:some_id)
      end
      it "should return nil if the key does not exist" do
        expect(ExampleStorable.find(:some_id)).to be_nil
      end
    end

    describe "self.create" do
      it "should raise DuplicateKey if there is an existing record" do
        example = ExampleStorable.create(:some_id)
        expect{
          ExampleStorable.create(:some_id)
        }.to raise_error(StorableDuplicateKey)
      end

      it "should create a new record" do
        expect{ ExampleStorable.create(:this_id) }.to change{ExampleStorable.count}.by(1)
      end

      it "should update attributes" do
        storable = ExampleStorable.create(:some_id, {:name => 'hello world'})
        expect(storable.reload.name).to eq('hello world')
      end

      it "should log a change" do
        newbie = ExampleStorable.create(:this_new_id)
        expect(newbie.changes.size).to eq(1)
        expect(newbie.changes.last.message).to eq("was created")
      end
    end

    describe "self.find_or_create" do
      it "should create a new record if one doesn't exist" do
        expect{ ExampleStorable.find_or_create(:this_id) }.to change{ExampleStorable.count}.by(1)
      end

      it "should find an existing record if one exists" do
        example = ExampleStorable.create(:this_id)
        ExampleStorable.find_or_create(:this_id)
      end
    end

    describe "self.all" do
      before :each do
        @this = ExampleStorable.create(:this)
        @not_this = AnotherStorable.create(:not_this)
        @that = ExampleStorable.create(:that)
      end

      it "should return all the record" do
        expect(ExampleStorable.all).to include(@this, @that)
        expect(ExampleStorable.all).not_to include(@not_this)
      end

      it "should mark them as not new records" do
        ExampleStorable.all.each do |r|
          expect(r).not_to be_new_record
        end
      end
    end

    describe "self.count" do
      before :each do
        ExampleStorable.create(:this)
        AnotherStorable.create(:this)
        ExampleStorable.create(:that)
      end

      it "should return the number of committed storables" do
        expect(ExampleStorable.count).to eq(2)
        expect(AnotherStorable.count).to eq(1)
      end
    end

    describe "save" do
      let(:new_record) { ExampleStorable.new(:an_id) }
      it "should commit to db" do
        expect{
          new_record.save
        }.to change{ ExampleStorable.count }.by(1)
      end
      it "should set @new_record = false" do
          expect{
            new_record.save
          }.to change{ new_record.new_record }.from(true).to(false)
      end
      it "should return true" do
        expect(new_record.save).to be_truthy
      end
    end

    describe "master_key" do
      it "should be by class" do
        expect(ExampleStorable.master_key).to eq('example')
        expect(AnotherStorable.master_key).to eq('another')
      end
    end

    describe "==" do
      it "should match class and id" do
        expect(ExampleStorable.new("thing") == ExampleStorable.new("thing")).to be_truthy
        expect(ExampleStorable.new("thing") == ExampleStorable.new("thing2")).to be_falsey
        expect(ExampleStorable.new("thing") == AnotherStorable.new("thing")).to be_falsey
      end
    end

  end
end

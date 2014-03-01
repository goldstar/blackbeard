require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe Storable do
    class ExampleStorable < Storable
      set_master_key :example
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
      it "should raise NotFound if the key does not exist" do
        expect{
          ExampleStorable.find(:some_id)
        }.to raise_error(StorableNotFound)
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

      it "should update attributes"
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
        ExampleStorable.all.should include(@this, @that)
        ExampleStorable.all.should_not include(@not_this)
      end

      it "should mark them as not new records" do
        ExampleStorable.all.each do |r|
          r.should_not be_new_record
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
        ExampleStorable.count.should == 2
        AnotherStorable.count.should == 1
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
    end

    describe "master_key" do
      it "should be by class" do
        ExampleStorable.master_key.should == 'example'
        AnotherStorable.master_key.should == 'another'
      end
    end

    describe "==" do
      it "should match class and id" do
        (ExampleStorable.new("thing") == ExampleStorable.new("thing")).should be_true
        (ExampleStorable.new("thing") == ExampleStorable.new("thing2")).should be_false
        (ExampleStorable.new("thing") == AnotherStorable.new("thing")).should be_false
      end
    end

  end
end

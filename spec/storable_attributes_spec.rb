require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Storable do
  class ExampleStorableAttrBase < Blackbeard::Storable
    integer_attributes :number
    string_attributes :foo, :name
    json_attributes :list
  end

  class ExampleStorableAttr < ExampleStorableAttrBase
    set_master_key :example
  end

  let(:example){ ExampleStorableAttr.create("id") }

  describe "json_attributes" do
    it "should not blow up when nil" do
        expect(example.list).to be_nil
    end

    it "should read and write" do
      example.list = ["hello", "world"]
      expect(example.list).to eq(["hello", "world"])
    end

    it "should not persist if not saved" do
      example.list = ["hello", "world"]
      expect(example.reload.list).not_to eq(["hello", "world"])
    end

    it "should persist if saved" do
      example.list = ["hello", "world"]
      example.save
      expect(example.reload.list).to eq(["hello", "world"])
    end

    it "should create a change log" do
      example.list = ["hello", "world"]
      expect{
        example.save
      }.to change{ example.changes.count }.by(1)
    end
  end

  describe "integer_attributes" do
    it "should be read and write" do
      example.number = 3
      expect(example.number).to eq(3)
    end

    it "should not persist if not saved" do
      example.number = 4
      expect(example.reload.number).not_to eq(4)
    end

    it "should persist when saved" do
      example.number = 5
      example.save

      expect(example.reload.number).to eq(5)
    end

    it "should create a change log" do
      example.number = 5
      expect{
        example.save
      }.to change{ example.changes.count }.by(1)
    end
  end

  describe "string_attributes" do
    it "should be read and write" do
      example.name = "Some name"
      expect(example.name).to eq("Some name")
    end

    it "should not persist if not saved" do
      example.name = "Some name"
      expect(example.reload.name).not_to eq("Some name")
    end

    it "should persist when saved" do
      example.name = "Some name"
      example.save
      expect(example.reload.name).to eq("Some name")
    end

    it "should create a change log" do
      example.name = "some name"
      expect{
        example.save
      }.to change{ example.changes.count }.by(1)
    end
  end

  describe "update_attributes" do
    let(:storable){ ExampleStorableAttr.create("id") }
    it "should not raise raise_error with non-attributes" do
      expect{
        storable.update_attributes(:foo => 'hello')
      }.to_not  raise_error
    end
    it "should update the attribute for known attributes" do
      expect{
        storable.update_attributes(:foo => 'hello')
      }.to change{ storable.foo }.from(nil).to('hello')
    end

    it "should update the attribute for known attributes even when strings" do
      expect{
        storable.update_attributes("foo" => 'hello')
      }.to change{ storable.foo }.from(nil).to('hello')
    end
    it "should persist the changes" do
      storable.update_attributes("foo" => 'hello')
      expect(storable.reload.foo).to eq('hello')
    end
  end

  describe "name" do
    let(:storable){ ExampleStorableAttr.create("id") }

    it "should return id by default" do
      expect{
        storable.update_attributes("name" => 'hello')
      }.to change{ storable.name }.from("id").to('hello')
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Storable do
  class ExampleStorableAttrBase < Blackbeard::Storable
    string_attributes :name
  end

  class ExampleStorableAttr < ExampleStorableAttrBase
    set_master_key :example
  end

  describe "string_attributes" do
    it "should be read and write" do
      example = ExampleStorableAttr.new("id")
      example.name = "Some name"
      example.name.should == "Some name"
    end

    it "should persist" do
      example = ExampleStorableAttr.new("id")
      example.name = "Some name"

      example_reloaded = ExampleStorableAttr.new("id")
      example_reloaded.name.should == "Some name"
    end
  end

  describe "update_attributes" do
    let(:storable){ ExampleStorableAttr.new("id") }
    it "should not raise raise_error with non-attributes" do
      expect{
        storable.update_attributes(:name => 'hello')
      }.to_not  raise_error
    end
    it "should update the attribute for known attributes" do
      expect{
        storable.update_attributes(:name => 'hello')
      }.to change{ storable.name }.from(nil).to('hello')
    end

    it "should update the attribute for known attributes even when strings" do
      expect{
        storable.update_attributes("name" => 'hello')
      }.to change{ storable.name }.from(nil).to('hello')
    end
  end
end
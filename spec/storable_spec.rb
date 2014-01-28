require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Storable do
  class ExampleStorable < Blackbeard::Storable
    set_master_key :example
    string_attributes :name
  end

  class AnotherStorable < Blackbeard::Storable
    set_master_key :another
  end

  it "should be able to instantiate" do
    expect{
      ExampleStorable.new(:some_id)
    }.to_not raise_error
  end

  describe "master_key" do
    it "should be by class" do
      ExampleStorable.master_key.should == 'example'
      AnotherStorable.master_key.should == 'another'
    end
  end

  describe "string_attributes" do
    it "should be read and write" do
      example = ExampleStorable.new("id")
      example.name = "Some name"
      example.name.should == "Some name"
    end

    it "should persist" do
      example = ExampleStorable.new("id")
      example.name = "Some name"

      example_reloaded = ExampleStorable.new("id")
      example_reloaded.name.should == "Some name"
    end
  end
end

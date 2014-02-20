require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Storable do
  class ExampleStorable < Blackbeard::Storable
    set_master_key :example
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

  describe "==" do
    it "should match class and id" do
      (ExampleStorable.new("thing") == ExampleStorable.new("thing")).should be_true
      (ExampleStorable.new("thing") == ExampleStorable.new("thing2")).should be_false
      (ExampleStorable.new("thing") == AnotherStorable.new("thing")).should be_false
    end
  end

end

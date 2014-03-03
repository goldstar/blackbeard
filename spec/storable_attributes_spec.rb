require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Storable do
  class ExampleStorableAttrBase < Blackbeard::Storable
    integer_attributes :number
    string_attributes :name
    json_attributes :list
  end

  class ExampleStorableAttr < ExampleStorableAttrBase
    set_master_key :example
  end

  let(:example){ ExampleStorableAttr.create("id") }

  describe "json_attributes" do
    it "should not blow up when nil" do
        example.list.should be_nil
    end

    it "should read and write" do
      example.list = ["hello", "world"]
      example.list.should == ["hello", "world"]
    end

    it "should not persist if not saved" do
      example.list = ["hello", "world"]
      example.reload.list.should_not == ["hello", "world"]
    end

    it "should persist if saved" do
      example.list = ["hello", "world"]
      example.save
      example.reload.list.should == ["hello", "world"]
    end
  end

  describe "integer_attributes" do
    it "should be read and write" do
      example.number = 3
      example.number.should == 3
    end

    it "should not persist if not saved" do
      example.number = 4
      example.reload.number.should_not == 4
    end

    it "should persist when saved" do
      example.number = 5
      example.save

      example.reload.number.should == 5
    end
  end

  describe "string_attributes" do
    it "should be read and write" do
      example.name = "Some name"
      example.name.should == "Some name"
    end

    it "should not persist if not saved" do
      example.name = "Some name"
      example.reload.name.should_not == "Some name"
    end

    it "should persist when saved" do
      example.name = "Some name"
      example.save

      example.reload.name.should == "Some name"
    end
  end

  describe "update_attributes" do
    let(:storable){ ExampleStorableAttr.create("id") }
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
    it "should persist the changes" do
      storable.update_attributes("name" => 'hello')
      storable.reload.name.should == 'hello'
    end
  end
end

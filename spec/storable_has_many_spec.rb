require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard

  class Thing < Storable
    set_master_key :things
  end

  class HasManyExample < Storable
    set_master_key :examples
    has_many :things => Thing
  end

  describe StorableHasMany do
    let(:example){ HasManyExample.new(:example) }
    let(:thing){ Thing.new(:foo) }

    it "should add and remove things" do
      example.add_thing(thing)
      expect{
        example.remove_thing(thing)
      }.to change{ example.has_thing?(thing) }.from(true).to(false)
    end

    it "should has_thing?" do
      example.add_thing(thing)
      example.has_thing?(thing).should be_true
    end

    it "should list things" do
      expect{
        example.add_thing(thing)
      }.to change{ example.things.count}.from(0).to(1)
    end

    it "should list thing_ids" do
      example.thing_ids.should == []
      example.add_thing(thing)
      example.thing_ids.should == [thing.id]
    end

    it "should list the keys" do
      example.thing_keys.should == []
      example.add_thing(thing)
      example.thing_keys.should == [thing.key]
    end
  end

end

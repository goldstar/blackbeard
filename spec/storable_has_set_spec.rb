require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard

  class HasSetExample < Storable
    set_master_key :examples
    has_set :things => :thing
  end

  describe StorableHasMany do
    let(:example){ HasSetExample.create(:example) }
    let(:thing) { "foo" }

    it "should add and remove things" do
      example.add_thing(thing)
      expect{
        example.remove_thing(thing)
      }.to change{ example.has_thing?(thing) }.from(true).to(false)
    end

    it "should add many things at once" do
      expect{
        example.add_things("thing1", "thing2")
      }.to change{ example.things.count }.by(2)
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
  end

end

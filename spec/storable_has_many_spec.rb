require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard

  class Thing < Storable
    set_master_key :things
  end

  class HasManyExample < Storable
    set_master_key :examples
    has_many :things => Thing
  end

  class HasManyFoo < Storable
    set_master_key :foos
    has_many :bars => 'HasManyBar'
  end

  class HasManyBar < Storable
    set_master_key :bars
    has_many :foos => 'HasManyFoo'
  end

  describe StorableHasMany do
    let(:example){ HasManyExample.create(:example) }
    let(:thing){ Thing.create(:foo) }

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

    describe "reciprocal has_many" do
      let(:bar){ HasManyBar.create(:bar_one) }
      let(:foo) { HasManyFoo.create(:foo_one) }

      describe "adding" do
        it "should reciprocate one way" do
          expect{
            bar.add_foo( foo )
          }.to change{ foo.has_bar?(bar) }.from(false).to(true)
        end

        it "should reciprocate and the other way" do
          expect{
            foo.add_bar( bar )
          }.to change{ bar.has_foo?(foo) }.from(false).to(true)
        end
      end

      describe "removing" do
        before :each do
          bar.add_foo(foo)
        end
        it "should reciprocate one way" do
          expect{
            bar.remove_foo( foo )
          }.to change{ foo.has_bar?(bar) }.from(true).to(false)
        end

        it "should reciprocate and the other way" do
          expect{
            foo.remove_bar( bar )
          }.to change{ bar.has_foo?(foo) }.from(true).to(false)
        end
      end

    end
  end

end

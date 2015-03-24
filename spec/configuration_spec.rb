require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe Configuration do
    let(:config) { Configuration.new }
    describe "define_group" do
      it "should store the block in group_definiations" do
        config.define_group(:hello) do |user,controller|
          "world"
        end
        expect(config.group_definitions[:hello].call).to eq('world')
      end
      it "should add segments if any" do
        config.define_group(:hello, ["world"]) do |user,controller|
          "world"
        end
        expect(Group.find(:hello).segments).to include("world")
      end
    end
  end
end

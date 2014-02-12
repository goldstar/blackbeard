require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe Configuration do
    let(:config) { Configuration.new }
    describe "define_group" do
      it "should store the block in group_definiations" do
        config.define_group(:hello) do |user,request|
          "world"
        end
        config.group_definitions[:hello].call.should == 'world'
      end
    end
  end
end

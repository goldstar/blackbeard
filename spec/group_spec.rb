require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Group do
  let(:group){ Blackbeard::Group.new('example') }
  let(:context){ double(:controller => double, :user => double) }
  describe "segment" do
    context "with no code defined" do
      it "should return nil" do
        group.segment_for(context).should be(nil)
      end
    end
    context "with code defined" do
      it "return nil for nil" do
        Blackbeard.config.define_group(:example){ |r,u| nil }
        group.segment_for(context).should be(nil)
      end
      it "return nil for false" do
        Blackbeard.config.define_group(:example){ |r,u| false }
        group.segment_for(context).should be(nil)
      end
      it "return string for true" do
        Blackbeard.config.define_group(:example){ |r,u| true }
        group.segment_for(context).should eq('example')
      end
      it "return string for string" do
        Blackbeard.config.define_group(:example){ |r,u| 'foo' }
        group.segment_for(context).should eq('foo')
      end
      it "return string for int" do
        Blackbeard.config.define_group(:example){ |r,u| 12 }
        group.segment_for(context).should eq('12')
      end
    end
  end

end

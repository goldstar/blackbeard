require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Blackbeard::Group do
  let(:group){ Blackbeard::Group.find_or_create('example') }
  let(:context){ double(:controller => double, :user => double) }
  describe "segment" do
    context "with no code defined" do
      it "should return nil" do
        expect(group.segment_for(context)).to be(nil)
      end
    end
    context "with code defined" do
      it "return nil for nil" do
        Blackbeard.config.define_group(:example){ |r,u| nil }
        expect(group.segment_for(context)).to be(nil)
      end
      it "return nil for false" do
        Blackbeard.config.define_group(:example){ |r,u| false }
        expect(group.segment_for(context)).to be(nil)
      end
      it "return string for true" do
        Blackbeard.config.define_group(:example){ |r,u| true }
        expect(group.segment_for(context)).to eq('example')
      end
      it "return string for string" do
        Blackbeard.config.define_group(:example){ |r,u| 'foo' }
        expect(group.segment_for(context)).to eq('foo')
      end
      it "return string for int" do
        Blackbeard.config.define_group(:example){ |r,u| 12 }
        expect(group.segment_for(context)).to eq('12')
      end
    end
  end

end

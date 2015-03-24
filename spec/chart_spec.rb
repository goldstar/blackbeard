require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe Chart do
    let(:title) { 'This is a title' }
    let(:chart){
      Chart.new(
        :title => title,
        :columns=>["Date","Total","Uniques"],
        :rows=>[
            [Date.today, 10.5, 12],
            [Date.today+1, 11.5, 13],
            [Date.today+2, 0, 1],
        ])
    }
    it "should put title and height in options" do
      expect(chart.options).to eq({:title => title, :height => 300})
    end

    describe "data" do
      it "should have cols" do
        expect(chart.data[:cols]).to eq([
          {:label=>"Date", :type=>"string"},
          {:label=>"Total", :type=>"number"},
          {:label=>"Uniques", :type=>"number"}
        ])
      end
      it "should have rows" do
        expect(chart.data[:rows]).to eq([
          {:c=>[{:v=>Date.today}, {:v=>10.5}, {:v=>12}]},
          {:c=>[{:v=>Date.today+1}, {:v=>11.5}, {:v=>13}]},
          {:c=>[{:v=>Date.today+2}, {:v=>0}, {:v=>1}]}
        ])
      end
    end

  end
end

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard

  class HasChangesExample < Storable
    set_master_key :examples
  end

  describe StorableHasChanges do
    let!(:example){ HasChangesExample.create(:example) }
    let(:other_example) { HasChangesExample.create(:other_example) }

    describe "#log_change" do

      it "should create a change log associated to object" do
        expect{
          example.log_change("+1")
        }.to change{ example.changes.count }.by(1)
      end

      it "should create a change" do
        expect{
          example.log_change("+1")
        }.to change{ Change.count }.by(1)
      end

      it "should create a change pointed to object" do
        example.log_change("+1")
        expect(Change.last.object).to eq(example)
        expect(Change.last.message).to eq("+1")
      end

    end
  end

end

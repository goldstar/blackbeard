require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe VisitorUserTracker do
    let(:user) { double(id: 42) }
    let(:visitor_id) { 58 }

    describe ".set_visitor_id_for_user" do
      it "sets the visitor_id for the given user_id" do
        described_class.set_visitor_id_for_user(user_id: user.id, visitor_id: visitor_id)
        actual_visitor_id = described_class.get_visitor_id_for_user(user.id)
        expect(actual_visitor_id).to eq(visitor_id)
      end

      context "when there is already a value for user_id" do
        before do
          hash_key = described_class.hash_key
          allow(described_class.db).to receive(:hash_get).with(hash_key, user.id).and_return(visitor_id)
        end

        it "nopes. I mean, no-ops" do
          described_class.get_visitor_id_for_user(user.id)
          described_class.set_visitor_id_for_user(user_id: user.id,
                                                  visitor_id: visitor_id)
          expect(described_class.db).to_not receive(:hash_set)
        end
      end

    end

  end
end

require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe AppRevision do
    # App Built on September 15th
    let(:pirate)  { Pirate.new }
    let(:user)    { double(:id => 1) }
    let(:context) { Context.new(pirate, user) }
    subject(:revision) { described_class.new('20110915', context) }

    it 'should initialize with string' do
      expect(revision.to_s).to eq '20110915.00'
    end

    context 'when passed an invalid string' do
      subject(:revision) { described_class.new('MONKEYS') }

      it 'defaults to the oldest revision' do
        expect(revision.to_s).to eq '0.00'
      end
    end

    describe 'should compare with similarly formatted version strings' do
      context 'when less' do
        it 'returns true for greater than' do
          # Api Changed on Sept 14th - release 7 - client should see this feature
          # expect(revision).to receive(:newer_participant_data).and_call_original
          expect(revision > '20110914.07').to be true
        end
      end

      context 'when equal' do
        it 'returns true for equal' do
          # Api Changed on Sept 15th - release 0 - client should see this feature
          # expect(revision).to receive(:newer_participant_data).and_call_original
          expect(revision == '20110915.00').to be true
        end
      end

      context 'when more' do
        it 'returns true for less' do
          # Api Changed on Sept 15th - release 1 - client should NOT see this feature
          # expect(revision).to receive(:older_participant_data).and_call_original
          expect(revision < '20110915.01').to be true
        end
      end

      context 'when compared with nonsense' do
        it 'is less than' do
          # Client Revision isn't valid - client will NOT see feature
          # note that this is backwards of the actual use case of this feature
          # it's unlikely that you would type in an invalid revision
          expect(revision > 'MONKEYS').to be true
          expect(revision < 'MONKEYS').to be false
          expect(revision == 'MONKEYS').to be false
        end
      end
    end

    def hour_id(time)
      time.strftime("%Y%m%d%H")
    end

    describe 'it record query information in the metrics collector' do
      let(:one_day_older) { described_class.new('20150913', context) }
      let(:two_days_older) { described_class.new('20150912', context) }
      let(:three_days_older) { described_class.new('20150911', context) }

      context 'when less' do
        it 'records queries in the "older" bucket' do
          one_day_older > 20150914.01
          two_days_older > 20150914.01
          three_days_older > 20150914.01


          # This is a little confusing - the left side is the _clients_
          # requested revision, and the right side is the revision you are
          # querying against - we store the metrics under "target revision" on
          # the RHS - each unique revision requested by a client will increment
          # the number of older requested revisions in a a given hour - since
          # these all happeend like _just now_ we'll see this as being this
          # hours value being 3 - meaning that 3 different client versions
          # were queried against this API version.

          hours_key = Blackbeard::Revision.find('20150914.01').older_revision_data.send(:hours_hash_key)
          expect(Blackbeard.config.db.hash_get_all(hours_key)).to eq({
            hour_id(Blackbeard.config.tz.now) => "3"
          })
        end
      end
    end

    describe 'it is an argument error if the "hard" revision comes first' do
      let(:one_day_older) { described_class.new('20150913', context) }

      context 'when does not matter' do
        it 'throws an argument error' do
          expect { 20140915.01 > one_day_older }.to raise_error(ArgumentError)
        end
      end
    end

    describe 'comparisons work and it puts them in the right bucket' do
      let(:one_day_newer) { described_class.new('20150915', context) }
      let(:one_day_older) { described_class.new('20150913', context) }
      let(:three_days_newer) { described_class.new('20150917', context) }

      it 'records them in the right bucket regardless of which way the arrow faces' do
        expect(one_day_older > 20150914.01).to be false
        expect(one_day_newer < 20150914.01).to be false
        expect(three_days_newer > 20150914.01).to be true

        hours_key = Blackbeard::Revision.find('20150914.01').older_revision_data.send(:hours_hash_key)
          expect(Blackbeard.config.db.hash_get_all(hours_key)).to eq({
            hour_id(Blackbeard.config.tz.now) => "1"
          })

        hours_key = Blackbeard::Revision.find('20150914.01').newer_revision_data.send(:hours_hash_key)
          expect(Blackbeard.config.db.hash_get_all(hours_key)).to eq({
            hour_id(Blackbeard.config.tz.now) => "2"
          })
      end
    end


    describe 'it record query information in the metrics collector' do
      let(:one_day_newer) { described_class.new('20150915', context) }
      let(:two_days_newer) { described_class.new('20150916', context) }
      let(:three_days_newer) { described_class.new('20150917', context) }

      context 'when less' do
        it 'records queries in the "older" bucket' do
          one_day_newer > 20150914.01
          two_days_newer > 20150914.01
          three_days_newer > 20150914.01

          hours_key = Blackbeard::Revision.find('20150914.01').newer_revision_data.send(:hours_hash_key)
          expect(Blackbeard.config.db.hash_get_all(hours_key)).to eq({
            hour_id(Blackbeard.config.tz.now) => "3"
          })
        end
      end
    end

  end
end

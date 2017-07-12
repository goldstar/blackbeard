require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

module Blackbeard
  describe RedisStore do
    describe "hashes" do
      it "should set and get" do
        db.hash_set('a_hash', 'hello', 'world')
        expect(db.hash_get('a_hash', 'hello')).to eq('world')
      end

      it "should multi set and get" do
        db.hash_multi_set('a_hash', {:one => 'two', :three => 'four'})
        expect(db.hash_multi_get('a_hash',['three','one'])).to eq(['four','two'])
      end

      it "should return empty array on multi get with no values" do
        expect(db.hash_multi_get('a_hash', [])).to eq([])
      end

      it "should not raise error on multi set with empty hash" do
        expect{
          db.hash_multi_set('a_hash', {})
        }.to_not raise_error
      end

      it "should set if field does not exist" do
        db.hash_set('a_hash', 'hello', 'world')
        db.hash_set_if_not_exists('a_hash', 'hello', 'bar')
        expect(db.hash_get('a_hash', 'hello')).to eq('world')
        db.hash_set_if_not_exists('a_hash', 'foo', 'bar')
        expect(db.hash_get('a_hash', 'foo')).to eq('bar')
      end

      it "should return lenth and keys" do
        db.hash_set('a_hash', 'foo', 'bar')
        db.hash_set('a_hash', 'hello', 'world')
        expect(db.hash_length('a_hash')).to eq(2)
        expect(db.hash_keys('a_hash')).to include('foo', 'hello')
      end

      it "should get all" do
        db.hash_set('a_hash', 'foo', 'bar')
        db.hash_set('a_hash', 'hello', 'world')
        expect(db.hash_get_all('a_hash')).to include('foo' => 'bar', 'hello' => 'world')
      end

      it "should increment by float" do
        db.hash_increment_by_float('a_hash', 'field', 1)
        db.hash_increment_by_float('a_hash', 'field', 2.5)
        expect(db.hash_get('a_hash', 'field')).to eq("3.5")
      end

      it "should increment by int" do
        db.hash_increment_by('a_hash', 'field', 1)
        db.hash_increment_by('a_hash', 'field', 2.5)
        expect(db.hash_get('a_hash', 'field')).to eq("3")
      end

      it "should determine if key exists" do
        expect{
          db.hash_set('a_hash', 'field', 'exists')
        }.to change{db.hash_field_exists('a_hash', 'field')}.from(false).to(true)
      end
    end

    describe "sets" do
      it "should add and remove" do
        db.set_add_member('a_set', 'foo')
        db.set_add_member('a_set', 'bar')
        expect(db.set_members('a_set')).to include('foo', 'bar')
        db.set_remove_member('a_set', 'bar')
        expect(db.set_members('a_set')).not_to include('bar')
      end

      it "should return true if added" do
        expect(db.set_add_member('a_set', 'foo')).to be(true)
        expect(db.set_add_member('a_set', 'foo')).to be(false)
      end

      it "should return all the members" do
        db.set_add_member('a_set', 'foo')
        db.set_add_member('a_set', 'bar')
        expect(db.set_members('a_set')).to include('foo', 'bar')
      end

      it "should set multiple members at once" do
        db.set_add_members('a_set', 'foo', ['bar', 'shag'])
        expect(db.set_members('a_set')).to include('foo', 'bar', 'shag')
      end

      it "should count the members" do
        db.set_add_members('a_set', 'foo', 'bar')
        expect(db.set_count('a_set')).to eq(2)
      end

      it "should count the union" do
        db.set_add_members('a_set', 'foo', 'bar')
        db.set_add_members('x_set', 'bar', 'world')
        expect(db.set_union_count('a_set','x_set')).to eq(3)
      end

    end

    describe "sorted set" do
      it "should set the member" do
        expect{
          db.sorted_set_add_member('sorted', 9000, 'foo')
        }.to change{ db.sorted_set_range_by_score('sorted').count }.by(1)
      end

      describe "ranges by score" do
        before :each do
          db.sorted_set_add_member('sorted', 1, 'one')
          db.sorted_set_add_member('sorted', 2, 'two')
          db.sorted_set_add_member('sorted', 3, 'three')
        end

        it "should return all with no limits" do
          expect(db.sorted_set_range_by_score('sorted')).to eq(['one','two','three'])
          expect(db.sorted_set_reverse_range_by_score('sorted')).to eq(['three','two','one'])
        end

        it "should respect min and max" do
          expect(db.sorted_set_range_by_score('sorted', :min => 2, :max => 2)).to eq(['two'])
          expect(db.sorted_set_reverse_range_by_score('sorted', :min => 2, :max => 2)).to eq(['two'])
        end

        it "should respect limit with count" do
          expect(db.sorted_set_range_by_score('sorted', :limit => [0, 2])).to eq(['one','two'])
          expect(db.sorted_set_reverse_range_by_score('sorted', :limit => [0,2])).to eq(['three','two'])
        end

        it "should work with limit as integer" do
          expect(db.sorted_set_range_by_score('sorted', :limit => 2)).to eq(['one','two'])
          expect(db.sorted_set_reverse_range_by_score('sorted', :limit => 2)).to eq(['three','two'])
        end

        it "should respect limit with offset" do
          expect(db.sorted_set_range_by_score('sorted', :limit => [1,2])).to eq(['two', 'three'])
          expect(db.sorted_set_reverse_range_by_score('sorted', :limit => [1,2])).to eq(['two', 'one'])
        end


        it "should respect limit and offset" do
          expect(db.sorted_set_range_by_score('sorted', :limit => [1,1])).to eq(['two'])
          expect(db.sorted_set_reverse_range_by_score('sorted', :limit => [1,1])).to eq(['two'])
        end

        it "should return tuples with scores" do
          expect(db.sorted_set_range_by_score('sorted', :limit => [0,1], :with_scores => true)).to eq([['one', 1.0]])
          expect(db.sorted_set_reverse_range_by_score('sorted', :limit => [0,1], :with_scores => true)).to eq([['three',3.0]])
        end
      end
    end

    describe "strings" do
      it "should get and set" do
        db.set('hello','world')
        expect(db.get('hello')).to eq('world')
      end

      it "should delete" do
        db.set('hello','world')
        expect{
          db.del('hello')
        }.to change{ db.get('hello') }.from('world').to(nil)
      end

      it "should get many at once" do
        db.set('hello','world')
        db.set('foo','bar')
        expect(db.multi_get('hello','herp', 'foo')).to eq(['world',nil,'bar'])
      end

      it "should increment" do
        db.increment('count')
        expect(db.get('count')).to eq('1')
        db.increment('count')
        expect(db.get('count')).to eq('2')
      end
    end
  end
end

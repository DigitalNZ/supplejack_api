require 'spec_helper'

module SupplejackApi
  describe RecordRedisQueue do
    let(:buffer) { SupplejackApi::RecordRedisQueue.new }

    before do
      Redis.any_instance.stub(:llen).and_return(10)
      # This because the return value of the Redis block is Redis:Future
      # Which had a .value method for the results
      # Recreating it with OpenStruct
      Redis.any_instance.stub(:lrange).and_return(OpenStruct.new(value: [1, 2, 3]))
    end

    describe 'dynamic methods' do
      [:push_to_index_buffer, :push_to_remove_buffer].each do |method|
        it "#{method} should exist" do
          expect(buffer).to respond_to(method)
        end
      end
    end

    describe '#pop_record_ids' do
      it 'returns ids from redis list' do
        expect(buffer.pop_record_ids).to eq [1, 2, 3]
      end
    end

    describe '#records_to_index' do
      it 'fetches records with ids from redis list' do
        expect(SupplejackApi.config.record_class).to receive(:where).with(:id.in => [1, 2, 3])
        buffer.records_to_index
      end
    end

    describe '#records_to_remove' do
      it 'fetches records with ids from redis list' do
        expect(SupplejackApi.config.record_class).to receive(:where).with(:id.in => [1, 2, 3])
        buffer.records_to_remove
      end
    end

    describe '#push_to_index_buffer' do
      it 'pushes ids to redis list' do
        expect_any_instance_of(Redis).to receive(:rpush).with('index_buffer_record_ids', 1).and_return(true)
        buffer.push_to_index_buffer([1])
      end
    end

    describe '#push_to_remove_buffer' do
      it 'pushes ids to redis list' do
        expect_any_instance_of(Redis).to receive(:rpush).with('remove_buffer_record_ids', 1).and_return(true)
        buffer.push_to_remove_buffer([1])
      end
    end

    # Protected methods

    describe '#count_for_buffer_type' do
      it 'fetches the count of ids in index list' do
        expect_any_instance_of(Redis).to receive(:llen).with('index_buffer_record_ids').and_return(10)
        buffer.send(:count_for_buffer_type, :index)
      end

      it 'fetches the count of ids in remove list' do
        expect_any_instance_of(Redis).to receive(:llen).with('remove_buffer_record_ids').and_return(10)
        buffer.send(:count_for_buffer_type, :remove)
      end
    end

    describe '#buffer_name' do
      it 'returns the redis key for index list' do
        expect(buffer.send(:buffer_name, :index)).to eq 'index_buffer_record_ids'
      end

      it 'returns the redis key for remove list' do
        expect(buffer.send(:buffer_name, :remove)).to eq 'remove_buffer_record_ids'
      end
    end
  end
end

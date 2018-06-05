require 'spec_helper'

module SupplejackApi
  describe IndexBuffer do
    let(:clear_index_buffer) { SupplejackApi::ClearIndexBuffer.new }

    context 'when indexing array of SupplejackApi.config.record_class' do
      before do
        # set 10 records to be indexed
        allow_any_instance_of(IndexBuffer).to receive(:records_to_index).and_return(create_list(:record,10))
        # raise error when trying to index the array
        allow(Sunspot).to receive(:index).with(Array).and_raise(StandardError)
      end

      it 'retries record by record if error is raised' do
        expect(Sunspot).to receive(:index).with(SupplejackApi.config.record_class).exactly(10).times
        clear_index_buffer.perform
      end

      it 'log error if single record fail after retrying' do
        allow(Sunspot).to receive(:index).with(SupplejackApi.config.record_class).and_raise(StandardError)

        expect(Rails.logger).to receive(:error).exactly(10).times
        clear_index_buffer.perform
      end
    end

    context 'when removing array of SupplejackApi.config.record_class' do
      before do
        # set 10 records to be removed
        allow_any_instance_of(IndexBuffer).to receive(:records_to_remove).and_return(create_list(:record,10))
        # raise error when trying to remove the array
        allow(Sunspot).to receive(:remove).with(Array).and_raise(StandardError)
      end

      it 'retries record by record if error is raised' do
        expect(Sunspot).to receive(:remove).with(SupplejackApi.config.record_class).exactly(10).times
        clear_index_buffer.perform
      end

      it 'log error if single record fail after retrying' do
        allow(Sunspot).to receive(:remove).with(SupplejackApi.config.record_class).and_raise(StandardError)

        expect(Rails.logger).to receive(:error).exactly(10).times
        clear_index_buffer.perform
      end
    end
  end
end

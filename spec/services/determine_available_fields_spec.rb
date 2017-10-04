RSpec.describe DetermineAvailableFields do
  describe '#call' do
    context 'when no group params are passed' do
      it 'returns the default groups' do
        service = described_class.new({ groups: [:default]})
        expect(service.call).to eq [:name, :address, :email, :default, :next_page, :next_record, :previous_page, :previous_record, :updated_at, :created_at]
      end

      it 'returns the default and verbose groups' do
        service = described_class.new({ groups: [:default, :verbose]})
        expect(service.call).to eq [:name, :address, :email, :children, :nz_citizen, :birth_date, :age, :landing_url, :subject, :default, :verbose, :next_page, :next_record, :previous_page, :previous_record, :updated_at, :created_at]
      end

      it 'includes fields that have been passed in the options hash' do
        service = described_class.new({ groups: [:default], fields: [:children]})
        expect(service.call).to eq [:name, :address, :email, :children, :default,  :next_page, :next_record, :previous_page, :previous_record]
      end
    end
  end
end

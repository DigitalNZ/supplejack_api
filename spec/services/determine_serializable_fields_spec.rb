RSpec.describe DetermineSerializableFields do
  describe '#call' do
    context 'when no group params are passed' do
      it 'returns the default groups' do
        service = DetermineSerializableFields.new({ groups: [:default]})
        expect(service.call).to eq [:name, :address, :email]
      end

      it 'returns the default and verbose groups' do
        service = DetermineSerializableFields.new({ groups: [:default, :verbose]})
        expect(service.call).to eq [:name, :address, :email, :children, :nz_citizen, :birth_date, :age, :landing_url]
      end

      it 'includes fields that have been passed in the options hash' do
        service = DetermineSerializableFields.new({ groups: [:default], fields: [:children]})
        expect(service.call).to eq [:name, :address, :email, :children]
      end
    end
  end
end

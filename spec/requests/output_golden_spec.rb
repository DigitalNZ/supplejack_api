# frozen_string_literal: true

require 'spec_helper'

# Pins the public JSON/XML output so framework upgrades cannot change it silently.
# Re-record only deliberately: GOLDEN=write bundle exec rspec spec/requests/output_golden_spec.rb
RSpec.describe 'Public output golden files', type: :request do
  let(:golden_dir) { Pathname.new(File.expand_path('../fixtures/golden', __dir__)) }
  let(:api_key)    { 'golden-api-key' }
  let(:stamp)      { Time.zone.parse('2026-01-02 03:04:05 +13:00') }

  let!(:user) { create(:user, authentication_token: api_key, name: 'Golden User', username: 'golden', email: 'golden@example.com') }
  let!(:record) do
    create(
      :record_with_fragment,
      id: BSON::ObjectId.from_string('5f0000000000000000000001'),
      record_id: 54_123,
      created_at: stamp,
      updated_at: stamp,
      fragments: [build(:record_fragment, name: 'Golden Record', birth_date: Time.utc(1990, 5, 6, 7, 8, 9))]
    )
  end

  def golden_path(name) = golden_dir.join(name)

  def normalise_json(body)
    sort_keys = lambda do |value|
      case value
      when Hash  then value.sort.to_h.transform_values { |val| sort_keys.call(val) }
      when Array then value.map { |val| sort_keys.call(val) }
      else value
      end
    end
    JSON.pretty_generate(sort_keys.call(JSON.parse(body)))
  end

  def normalise_xml(body)
    body.gsub(/>\s+</, '><').strip
  end

  def check_golden(name, body)
    normalised = name.end_with?('.json') ? normalise_json(body) : normalise_xml(body)

    if ENV['GOLDEN'] == 'write'
      File.write(golden_path(name), "#{normalised}\n")
    else
      expect(normalised).to eq(File.read(golden_path(name)).chomp)
    end
  end

  before do
    allow_any_instance_of(SupplejackApi::RecordSearch).to receive(:results).and_return([record])
    allow_any_instance_of(SupplejackApi::RecordSearch).to receive(:total).and_return(1)
  end

  %w[json xml].each do |format|
    describe "format #{format}" do
      it 'pins GET /v3/records/:id' do
        get "/v3/records/#{record.record_id}.#{format}", params: { api_key:, fields: 'verbose' }

        expect(response.status).to eq(200)
        check_golden("record.#{format}", response.body)
      end

      it 'pins GET /v3/records search' do
        get "/v3/records.#{format}", params: { api_key:, text: 'golden', fields: 'verbose' }

        expect(response.status).to eq(200)
        check_golden("search.#{format}", response.body)
      end

      it 'pins a bad api_key response' do
        get "/v3/records/#{record.record_id}.#{format}", params: { api_key: 'not-a-real-key' }

        expect(response.status).to eq(403)
        check_golden("forbidden.#{format}", response.body)
      end

      it "returns the #{format} media type" do
        get "/v3/records/#{record.record_id}.#{format}", params: { api_key: }

        expect(response.media_type).to eq(format == 'xml' ? 'application/xml' : 'application/json')
      end
    end
  end
end

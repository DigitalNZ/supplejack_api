RSpec.describe PerformMergePatch do
  let(:story) { create(:story) }
  let(:description) { 'description' }
  let(:tags) { ['tags', 'go', 'here'] }
  let(:patch) do
    {
      description: description,
      tags: tags
    }
  end
  let(:service) { PerformMergePatch.new(StoriesApi::V3::Schemas::Story, StoriesApi::V3::Presenters::Story.new) }
  let!(:merge_result) { service.call(story, patch) }

  it 'updates the model fields with the patch fields' do
    expect(story.tags).to eq(tags)
    expect(story.description).to eq(description)
  end

  context 'validating the updated model against the schema' do
    let(:patch) { super().update(description: 123) }

    # Suspended till subject to tag syn is removed
    # it 'does not modify the model if the Schema validation fails' do
    #   expect(story.tags).to eq(['story', 'tags'])
    # end

    it 'returns false if validation fails' do
      expect(merge_result).to eq(false)
    end
  end

  it 'does not save the model' do
    skip 'TODO: Figure out how to check if a mongoid model has been saved'
  end
end

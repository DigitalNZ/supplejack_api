# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeprecationBehavior do
  let(:engine_frame) { "#{DeprecationBehavior::ENGINE_ROOT}/app/models/supplejack_api/record.rb:10:in 'x'" }
  let(:rails_frame)  { "#{Gem.path.first}/gems/activesupport-7.2.3.2/lib/active_support/deprecation.rb:1:in 'warn'" }
  let(:ams_frame)    { "#{Gem.path.first}/gems/active_model_serializers-0.10.14/lib/ams.rb:5:in 'x'" }
  let(:git_frame)    { "#{Gem.path.first}/bundler/gems/sunspot-abc123/lib/sunspot.rb:5:in 'x'" }

  def classify(*frames)
    expect { described_class.call('msg', frames) }.to output.to_stderr_from_any_process
    :stderr
  rescue ActiveSupport::DeprecationException
    :raise
  end

  it 'raises for an engine frame' do
    expect(classify(engine_frame)).to eq(:raise)
  end

  it 'raises for Rails-only frames followed by an engine frame' do
    expect(classify(rails_frame, rails_frame, engine_frame)).to eq(:raise)
  end

  it 'warns for an active_model_serializers frame (not treated as Rails)' do
    expect(classify(rails_frame, ams_frame, engine_frame)).to eq(:stderr)
    expect { described_class.call('msg', [ams_frame]) }.to output(/DEPRECATION \(gem\): msg/).to_stderr
  end

  it 'warns for a git-installed bundler gem frame' do
    expect(classify(rails_frame, git_frame, engine_frame)).to eq(:stderr)
  end
end

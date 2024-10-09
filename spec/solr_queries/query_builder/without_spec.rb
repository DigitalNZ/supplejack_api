# frozen_string_literal: true

require 'spec_helper'

module QueryBuilder
  describe Without do
    let(:search) { Sunspot.new_search(SupplejackApi::Record) }

    before do
      Sunspot.session = SunspotMatchers::SunspotSessionSpy.new(Sunspot.session)
      @session = Sunspot.session

      allow(SupplejackApi::Search).to receive(:role_collection_restrictions) { [] }
    end

    describe '#initialize' do
      context 'with empty params' do
        subject { described_class.new(search, {}) }

        it { is_expected.to have_attributes(without_hash: {}) }
      end

      context 'with given params' do
        subject { described_class.new(search, { title: ['keyword'] }) }

        it { is_expected.to have_attributes(without_hash: { title: ['keyword'] }) }
      end
    end

    describe '#call' do
      subject! { described_class.new(search, { title: ['keyword'] }).call }

      it 'call'
    end
  end
end

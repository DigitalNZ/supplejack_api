# frozen_string_literal: true

require 'spec_helper'

module QueryBuilder
  describe AndOrFilters do
    let(:search) { Sunspot.new_search(SupplejackApi::Record) }
    let(:empty_params) do
      SupplejackApi::SearchParams.new(model_class: SupplejackApi::Record, schema_class: RecordSchema)
    end
    let(:flat_params) do
      SupplejackApi::SearchParams.new(
        model_class: SupplejackApi::Record,
        schema_class: RecordSchema,
        exclude_filters_from_facets: true,
        facets: 'test',
        all: { title: 'keyword' },
        any: { description: 'keyword' }
      )
    end

    before do
      Sunspot.session = SunspotMatchers::SunspotSessionSpy.new(Sunspot.session)
      @session = Sunspot.session

      allow(SupplejackApi::Search).to receive(:role_collection_restrictions) { [] }
    end

    describe '#initialize' do
      context 'with empty params' do
        subject { described_class.new(search, empty_params) }

        it { is_expected.to have_attributes(conjunction_condition: {}) }
        it { is_expected.to have_attributes(disjunction_condition: {}) }
        it { is_expected.to have_attributes(exclude_filters_from_facets: false) }
        it { is_expected.to have_attributes(facets: []) }
      end

      context 'with given params' do
        subject { described_class.new(search, flat_params) }

        it { is_expected.to have_attributes(conjunction_condition: { title: 'keyword' }) }
        it { is_expected.to have_attributes(disjunction_condition: { description: 'keyword' }) }
        it { is_expected.to have_attributes(exclude_filters_from_facets: false) }
        it { is_expected.to have_attributes(facets: []) }
      end
    end

    describe '#call' do
      subject! { described_class.new(search, flat_params).call }

      it 'applies the conjunction operator on fulltext' do
        Sunspot.session.should have_search_params(:fulltext) {
          all do
            fulltext 'keyword', fields: :title
          end
        }
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  module Support
    describe FragmentHelpers do
      let(:record) { build(:record_with_fragment, record_id: 1234) }

      describe '#before_save' do
        it 'should call merge_fragments' do
          expect(record).to receive(:merge_fragments)
          record.save
        end
      end

      describe 'valiations' do
        it 'should be valid' do
          expect(record).to be_valid
        end

        context 'duplicate source_ids' do
          before do
            record.fragments << build(:record_fragment, source_id: 'source_name')
          end

          it 'should not be valid' do
            expect(record).to_not be_valid
          end
        end
      end

      describe '#source_ids' do
        it 'should return an array with a single source_id' do
          expect(record.source_ids).to eq ['source_name']
        end

        context 'multiple fragments' do
          before do
            record.fragments << build(:record_fragment, source_id: 'another_source')
          end

          it 'should return an array with the source_ids' do
            expect(record.source_ids).to eq %w[source_name another_source]
          end
        end
      end

      describe '#duplicate_source_ids?' do
        it 'should return false' do
          expect(record.duplicate_source_ids?).to be_falsey
        end

        context 'duplicate source_ids' do
          before do
            record.fragments << build(:record_fragment, source_id: 'source_name')
          end

          it 'should return true' do
            expect(record.duplicate_source_ids?).to be_truthy
          end
        end
      end

      describe '#primary_fragment' do
        let(:record) { build(:record) }
        before { record.save }

        it 'returns the fragment with priority 0' do
          # fragment1 = record.fragments.create(name: 'John', priority: 1)
          fragment0 = record.fragments.create(name: 'John', priority: 0)
          expect(record.primary_fragment).to eq fragment0
        end

        it 'returns a new fragment with priority 0' do
          expect(record.primary_fragment).to be_a ApiRecord::RecordFragment
          expect(record.primary_fragment.priority).to eq 0
        end

        it 'should build a primary fragment with default attributes' do
          expect(record.primary_fragment(name: 'John').name).to eq 'John'
        end
      end

      describe 'merge_fragments' do
        let(:record) { build(:record_with_fragment) }
        let(:primary) { record.fragments.where(priority: 0).first }
        let(:secondary) { record.fragments.where(priority: -1).first }

        it 'should delete any existing merged fragment' do
          record.merged_fragment = build(:record_fragment)
          record.save
          expect(record.merged_fragment).to be_nil
        end

        context 'one fragment' do
          it 'should not save the merged fragment' do
            record.merge_fragments
            expect(record.merged_fragment).to be_nil
          end
        end

        context 'multiple fragments' do
          before(:each) do
            fragment = build(:record_fragment,
                             name: 'James Smith',
                             email: ['jamessmith@example.com'],
                             source_id: 'another_source',
                             priority: -1)

            record.fragments << fragment
            record.reload.save!
          end

          it 'unsets the priority field' do
            record.save
            expect(record.merged_fragment.priority).to be_nil
          end

          context 'single value fields' do
            it 'should store the first non-nil value of the field' do
              primary.name = nil
              record.save
              expect(record.merged_fragment.name).to eq 'James Smith'
            end
          end

          context 'multi-value fields' do
            it 'should store the merged values of the field' do
              expect(record.merged_fragment.email).to eq ['jamessmith@example.com', 'johndoe@example.com']
            end

            it 'should not return duplicate values' do
              primary.email = ['johndoe@example.com', 'jamessmith@example.com']
              record.save
              expect(record.merged_fragment.email).to eq ['jamessmith@example.com', 'johndoe@example.com']
            end

            it 'should not return nil values' do
              secondary.email = nil
              record.save
              expect(record.merged_fragment.email).to eq ['johndoe@example.com']
            end

            context 'merge_as_single_value: true' do
              before(:each) do
                official_fragment = build(:record_fragment,
                                          empowering_provisions: %w[a b c],
                                          multi_value_merge: %w[1 2 3],
                                          source_id: 'official',
                                          priority: -999)

                source_fragment = build(:record_fragment,
                                        empowering_provisions: %w[d e f],
                                        multi_value_merge: %w[4 5 6],
                                        source_id: 'source',
                                        priority: -998)

                record.fragments << official_fragment
                record.fragments << source_fragment
                record.reload.save!
              end

              it 'should only display the highest priority multi value field when merge_as_single_value: true' do
                expect(record.merged_fragment.empowering_provisions).to eq %w[a b c]
              end

              it 'falls back to the second highest priority if the highest priority does not have a value' do
                record.fragments.find_by(source_id: 'official').empowering_provisions = nil
                record.save

                expect(record.merged_fragment.empowering_provisions).to eq %w[d e f]
              end

              it 'does not merge array fields as single values when they are not specified in the RecordSchema' do
                expect(record.merged_fragment.multi_value_merge).to eq %w[1 2 3 4 5 6]
              end
            end
          end
        end
      end

      describe '#method_missing' do
        let(:record) { create(:record_with_fragment) }

        context 'no fragments' do
          let(:record) { create(:record) }

          it 'should return nil' do
            expect(record.nz_citizen).to be_nil
          end
        end

        context 'single fragment' do
          it 'should return a single value field from merged_fragment' do
            expect(record.name).to eq 'John Doe'
          end

          it 'returns an array for an empty mutli-value field' do
            expect(record.contact).to eq []
          end
        end

        context 'multiple fragments' do
          before(:each) do
            fragment = build(:record_fragment,
                             email: ['jamessmith@example.com'],
                             source_id: 'another_source')
            record.fragments << fragment
            record.reload.save!
          end

          it 'should return a single value field from merged_fragment' do
            expect(record.name).to eq 'John Doe'
          end

          it 'should return the multi-value field values from merged_fragment' do
            expect(record.email).to eq ['johndoe@example.com', 'jamessmith@example.com']
          end
        end

        # context 'namespaced field names' do
        #   it 'should translate namespaced field names into their stored field name' do
        #     record.fragments.first.stub(:dc_name) { 'Joe Bloggs' }
        #     record.public_send(:'dc:name')).to eq 'Joe Bloggs'
        #   end
        # end
      end

      describe '#sorted_fragments' do
        it 'returns a list of fragments sorted by priority' do
          record.fragments.build(priority: 10)
          record.fragments.build(priority: -1)
          record.fragments.build(priority: 5)

          expect(record.sorted_fragments.map(&:priority)).to eq [-1, 0, 5, 10]
        end
      end

      describe '#find_fragment' do
        before { record.save }

        let!(:fragment) { record.fragments.create(source_id: 'thumbnails_enrichment') }

        it 'should find a fragment by source_id' do
          expect(record.find_fragment('thumbnails_enrichment')).to eq fragment
        end

        it "should return nil when it doesn't find a fragment" do
          expect(record.find_fragment('nlnzcat')).to be_nil
        end
      end
    end
  end
end

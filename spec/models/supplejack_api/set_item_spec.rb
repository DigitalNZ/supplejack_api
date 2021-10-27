# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe SetItem do
    let(:user_set) { FactoryBot.build(:user_set) }
    let(:set_item) do
      user_set.set_items.build(record_id: 10, position: 1,
                               type: 'embed', sub_type: 'record',
                               content: { id: 10 })
    end

    before(:each) do
      allow(user_set).to receive(:record) { double(:record, record_id: 4321, touch: true) }
      allow(user_set).to receive(:update_record)
    end

    context 'validations' do
      it 'is not valid when record_id is not a number' do
        set_item.record_id = Faker::Lorem.word

        expect(set_item).to be_invalid
      end

      it 'is valid when the record_id is a number in string format' do
        set_item.record_id = '1234'

        expect(set_item.record_id).to eq 1234
        expect(set_item).to be_valid
      end

      it 'is not valid when the record_id already exists in another set item' do
        user_set.set_items.build(record_id: 2, position: 1, type: 'embed', sub_type: 'record')
        user_set.save
        set_item = user_set.set_items.build(record_id: 2, position: 2, type: 'embed', sub_type: 'record')

        expect(set_item).to be_invalid
      end

      it 'is not valid when trying to add a set to itself' do
        allow(user_set).to receive(:record) { double(:record, record_id: 1234) }
        set_item = user_set.set_items.build(record_id: 1234, position: 1)

        expect(set_item).to be_invalid
      end

      it 'should allow set_item to be added to user_set without an associated Record' do
        allow(user_set).to receive(:record)
        set_item = user_set.set_items.build(record_id: 1234,
                                            position: 1,
                                            type: 'embed',
                                            sub_type: 'record',
                                            content: { id: 1234 })

        expect(set_item).to be_valid
      end

      it 'is not valid when type is not text or embed' do
        allow(user_set).to receive(:record)
        set_item = user_set.set_items.build(record_id: 1234, position: 1, type: 'integer', sub_type: 'record')

        expect(set_item).to be_invalid
      end

      context 'when type is record' do
        it 'is not valid without record id in content id' do
          allow(user_set).to receive(:record)
          set_item = user_set.set_items.build(record_id: 1234, position: 1, type: 'embed', sub_type: 'record')

          expect(set_item).to be_invalid
        end

        it 'is valid with record id in content id' do
          allow(user_set).to receive(:record)
          set_item = user_set.set_items.build(record_id: 1234,
                                              position: 1,
                                              type: 'embed',
                                              sub_type: 'record',
                                              content: { id: 1234 })
          expect(set_item).to be_valid
        end

        it 'is not valid with meta alignment value not in left, center or right' do
          allow(user_set).to receive(:record)
          set_item = user_set.set_items.build(record_id: 1234,
                                              position: 1,
                                              type: 'embed',
                                              sub_type: 'record',
                                              content: { id: 1234 },
                                              meta: { alignment: 'top' })

          expect(set_item).to be_invalid
        end

        %w[left center right].each do |alignment|
          it "is valid with meta alignment value #{alignment}" do
            allow(user_set).to receive(:record)
            set_item = user_set.set_items.build(record_id: 1234,
                                                position: 1,
                                                type: 'embed',
                                                sub_type: 'record',
                                                content: { id: 1234 },
                                                meta: { alignment: alignment })

            expect(set_item).to be_valid
          end
        end
      end

      context 'when type is text' do
        it 'is not valid when sub_type is not heading or rich-text' do
          set_item = user_set.set_items.build(position: 1, type: 'text', sub_type: 'sub-heading')

          expect(set_item).to be_invalid
        end

        context 'when sub_type is heading' do
          it 'is not valid without content value' do
            set_item = user_set.set_items.build(position: 1,
                                                type: 'text',
                                                sub_type: 'heading',
                                                content: { not_value: 1 })

            expect(set_item).to be_invalid
          end

          it 'is valid with content value' do
            set_item = user_set.set_items.build(position: 1, type: 'text',
                                                sub_type: 'heading', content: { value: 'Heading' })

            expect(set_item).to be_valid
          end

          it 'is not valid with meta size not in 1 to 6' do
            set_item = user_set.set_items.build(position: 1, type: 'text',
                                                sub_type: 'heading', meta: { size: 12 },
                                                content: { value: 'Heading' })

            expect(set_item).to be_invalid
          end

          it 'is valid with meta size from 1 to 6' do
            set_item = user_set.set_items.build(position: 1, type: 'text',
                                                sub_type: 'heading', meta: { size: 1 },
                                                content: { value: 'Heading' })
            expect(set_item).to be_valid
          end
        end

        context 'when sub_type is rich-text' do
          it 'is not valid without content value' do
            set_item = user_set.set_items.build(position: 1, type: 'text',
                                                sub_type: 'heading', content: { not_value: 1 })

            expect(set_item).to be_invalid
          end

          it 'is valid with content value' do
            set_item = user_set.set_items.build(position: 1,
                                                type: 'text',
                                                sub_type: 'heading',
                                                content: { value: '<p>Text</p>' })

            expect(set_item).to be_valid
          end
        end
      end
    end

    context 'callbacks' do
      it 'calls set_position before_validation' do
        set_item = user_set.set_items.build(record_id: 20)
        expect(set_item).to receive(:set_position)

        set_item.save
      end

      it 'updates the user_set updated at field when an item is updated and saved' do
        old_time = user_set.updated_at
        set_item.position = 2
        set_item.save!

        expect(user_set.updated_at).to_not eq old_time
      end
    end

    it 'delegates record fields to the :record object' do
      record = FactoryBot.create(:record_with_fragment)
      set_item.record = record

      expect(set_item.name).to eq record.name
      expect(set_item.address).to eq record.address
    end

    it "returns nil for any record field if the record doesn't exist" do
      %i[name address].each do |attr|
        expect(set_item.send(attr)).to be_nil
      end
    end

    describe '#set_position' do
      context 'with a set item' do
        before(:each) do
          user_set.set_items.build(record_id: 1, position: 1)
          user_set.save
        end

        it 'positions the set item at the end' do
          set_item = user_set.set_items.build(record_id: 2)
          set_item.set_position

          expect(set_item.position).to eq 2
        end

        it "doesn't override the position when already set" do
          set_item = user_set.set_items.build(record_id: 2, position: 4)
          set_item.set_position

          expect(set_item.position).to eq 4
        end
      end

      context 'without set items' do
        it 'sets the position to 1' do
          set_item = user_set.set_items.build(record_id: 2)
          set_item.set_position

          expect(set_item.position).to eq 1
        end
      end
    end

    describe '#reindex_record' do
      let(:record) { double(:record) }

      it 'finds the record and calls index' do
        expect(Record).to receive(:custom_find).with(set_item.record_id) { record }
        expect(record).to receive(:index)

        set_item.reindex_record
      end
    end

    describe '#content' do
      let(:set_item_script) { build(:story_item, :script_value) }
      let(:set_item_inline) { build(:story_item, :inline_style_value) }

      it 'removes script tags' do
        expect(set_item_script.content[:value]).to eq 'alert("test");&lt;script&gt;'
      end

      it 'removes inline styles' do
        expect(set_item_inline.content[:value]).to eq '<p>my paragraph</p>'
      end
    end

    describe 'hash fields' do
      it 'symbolizes the keys on the hash fields when created' do
        set_item = create(:story_item)

        expect(set_item.meta).to have_key :size
        expect(set_item.content).to have_key :value
      end

      it 'symbolizes the keys on the hash fields when found' do
        set_item = create(:story_item)
        set_item = UserSet.find(set_item.user_set.id).set_items.first

        expect(set_item.meta).to have_key :size
        expect(set_item.content).to have_key :value
      end
    end

    describe 'timestamps' do
      let!(:user_set) { create(:user_set_with_set_item) }

      it 'has the created_at field' do
        expect(user_set.set_items.first.created_at).not_to be_nil
      end

      it 'has the updated_at field' do
        expect(user_set.set_items.first.updated_at).not_to be_nil
      end
    end
  end
end

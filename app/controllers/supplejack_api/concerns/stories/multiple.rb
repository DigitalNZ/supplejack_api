# frozen_string_literal: true

module SupplejackApi
  module Concerns
    module Stories
      module Multiple
        def multiple_add
          stories = multiple_stories_params['stories'].each_with_object([]) do |story, stories_array|
            set = SupplejackApi::UserSet.custom_find(story['id'])
            return render_error_with(I18n.t('errors.story_not_found', id: story['id']), :not_found) unless set

            authorize(set)
            stories_array.push(set)
          end

          changes = multiple_stories_params['stories'].each_with_object([]) do |story_params, changes_array|
            set = stories.find { |s| s.id.to_s == story_params['id'] }

            item_ids = story_params['items'].each_with_object([]) do |item, ids|
              item = set.set_items.build(item)

              return render_error_with(item.errors.messages.values.join(', '), :bad_request) unless item.valid?

              ids.push(item.id)
            end

            set.save!

            changes_array.push({
                                 story_id: story_params['id'],
                                 item_ids: item_ids
                               })
          end

          render json: changes
        end

        def multiple_remove
          stories = multiple_stories_params['stories'].each_with_object([]) do |story, stories_array|
            set = SupplejackApi::UserSet.custom_find(story['id'])
            return render_error_with(I18n.t('errors.story_not_found', id: story['id']), :not_found) unless set

            authorize(set)
            stories_array.push(set)
          end

          multiple_stories_params['stories'].each do |story_params|
            set = stories.find { |s| s.id.to_s == story_params['id'] }

            story_params['items'].each do |item|
              set_item = set.set_items.find_by_id(item[:id])

              return render json: { errors: I18n.t('errors.record_not_found', id: item[:id]) },
                            status: :not_found unless set_item

              set_item.destroy!
            end

            set.save!
          end

          head :no_content
        end
      end
    end
  end
end

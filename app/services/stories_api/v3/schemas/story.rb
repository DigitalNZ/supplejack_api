# # frozen_string_literal: true

# module StoriesApi
#   module V3
#     module Schemas
#       Story = Dry::Validation.Schema do
#         configure do
#           def valid_block?(block)
#             StoryItem::BlockValidator.new.call(block).success?
#           end

#           def not_nil?(value)
#             !value.nil?
#           end

#           def self.messages
#             super.merge(
#               # TODO: Figure out how to make this error message actually useful
#               en: { errors: { valid_block?: 'Block was not valid' } }
#             )
#           end
#         end

#         required(:id).filled(:str?)
#         required(:name).filled(:str?)
#         required(:description) { str? }
#         required(:privacy).filled(included_in?: %(hidden private public))
#         required(:copyright).filled(included_in?: [0, 1, 2])
#         required(:featured).filled(:bool?)
#         required(:approved).filled(:bool?)
#         required(:tags).each(:str?)
#         required(:number_of_items).filled(:int?, gteq?: 0)
#         required(:contents).each(:valid_block?)
#         optional(:cover_thumbnail)
#         optional(:subjects).each(:str?)
#       end
#     end
#   end
# end

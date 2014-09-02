# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class SetItem
    include Mongoid::Document
  
    # TODO DETERMINE SET FIELDS THIS
    ATTRIBUTES = RecordSchema.groups[:default].fields

    attr_accessor :record

    embedded_in :user_set, class_name: 'SupplejackApi::UserSet'

    field :record_id,   type: Integer
    field :position,    type: Integer

    validates :record_id,   presence: true, uniqueness: true, numericality: { greater_than: 0 }
    validates :position,    presence: true

    before_validation :set_position

    # Dynamically define methods for the attributes that get added to the set_item from
    # the actual Record.
    #
    ATTRIBUTES.each do |record_attr|
      define_method(record_attr) do
        self.record.try(:send, record_attr)
      end
    end

    # Set the default position as the last in the set, if not defined.
    #
    def set_position
      unless self.position
        positions = self.user_set.set_items.map(&:position)
        self.position = positions.compact.max.to_i + 1
      end
    end
  end
end

# frozen_string_literal: true

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class SourceAuthoritySerializer < ActiveModel::Serializer
    attribute '@type' do
      object.concept_type
    end

    ConceptSchema.fields.each do |name, _definition|
      attribute name do
        object.public_send(name)
      end
    end
  end
end

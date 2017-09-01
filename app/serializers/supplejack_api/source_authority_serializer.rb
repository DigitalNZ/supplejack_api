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

    attributes :_mn_family_name, :_mn_given_name, :altLabel, :biographicalInformation,
               :birthYear, :concept_id, :concept_score, :dateOfBirth, :dateOfDeath, :deathYear,
               :familyName, :givenName, :internal_identifier, :name, :prefLabel, :sameAs,
               :source_id, :source_name, :url, :updated_at, :created_at

    # def serializable_hash
    #   hash = {}
    #   hash['@type'] = object.concept_type
    #   hash = hash.merge!(attributes)
    #   hash
    # end
  end
end

# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

module SupplejackApi
  class Concept
    include Mongoid::Document
    include Mongoid::Timestamps

    # TODO: Update namespace
    # include ApiConcept::FragmentHelpers

    store_in collection: 'concepts'

    embeds_many :fragments, cascade_callbacks: true, class_name: 'SupplejackApi::ApiConcept::ConceptFragment'
    embeds_one :merged_fragment, class_name: 'SupplejackApi::ApiConcept::ConceptFragment'

    before_save :merge_fragments

    auto_increment :concept_id, session: 'strong', collection: 'concepts'

    field :internal_identifier,         type: String
    field :landing_url,                 type: String
    field :status,                      type: String

    # TODO: Abstracted into shared
    def merge_fragments
      self.merged_fragment = nil

      if self.fragments.size > 1
        self.merged_fragment = ConceptFragment.new

        ConceptFragment.mutable_fields.each do |name, field_type|
          if field_type == Array
            values = Set.new
            sorted_fragments.each do |s| 
              values += Array(s.public_send(name))
            end
            self.merged_fragment.public_send("#{name}=", values.to_a)
          else
            values = sorted_fragments.to_a.map {|s| s.public_send(name) }
            self.merged_fragment.public_send("#{name}=", values.compact.first)
          end
        end
      end
    end

  end
end

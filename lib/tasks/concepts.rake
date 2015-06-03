# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'json'

namespace :concepts do
	desc 'Import concepts'
  task import_concepts: :environment do
    puts 'Importing concepts'

    file = File.read("#{Rails.root}/db/concepts.json")
    concepts_hash = JSON.parse(file)

    concepts_hash.each do |concept|
    	existing_concept = SupplejackApi::Concept.where(concept_id: concept['concept_id']).first
    	SupplejackApi::Concept.create(concept) if existing_concept.nil?
    end
  end

  desc 'Import source authorities'
  task import_source_authorities: :environment do
    puts 'Importing source authorities'

    file = File.read("#{Rails.root}/db/source_authorities.json")
    source_authorities_hash = JSON.parse(file)

    SupplejackApi::SourceAuthority.delete_all

    source_authorities_hash.each do |source_authority|
    	concept = SupplejackApi::Concept.where(concept_id: source_authority['concept_id']).first
    	concept.source_authorities << SupplejackApi::SourceAuthority.create!(source_authority) if concept
    end
  end
end
# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

class ConceptSchema < SupplejackApi::SupplejackSchema

  # Fields
  string    :@id
  string    :@type
  string    :label
  string    :description
  datetime  :dateOfBirth
  datetime  :dateOfDeath
  string    :placeOfBirth
  string    :placeOfDeath
  string    :gender
  string    :isRelatedTo,   multi_value: true
  string    :hasMet,        multi_value: true
  string    :sameAs,        multi_value: true
  string    :name

  build_object_id

end

# frozen_string_literal: true



module SupplejackApi
  class Record
    include Support::Storable
    include Support::Searchable
    include Support::Harvestable
    include Support::FragmentHelpers
    include SupplejackApi::Concerns::Record
  end
end

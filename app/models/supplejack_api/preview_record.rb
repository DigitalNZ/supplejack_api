module SupplejackApi
  class PreviewRecord
    # These records are used for previewing in squirrel, expire after 60 seconds

    include ApiRecord::Storable
    include ApiRecord::FragmentHelpers
    include ApiRecord::Harvestable
  end
end
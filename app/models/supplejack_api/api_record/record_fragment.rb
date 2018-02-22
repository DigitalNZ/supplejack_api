# frozen_string_literal: true



module SupplejackApi
  module ApiRecord
    class RecordFragment < SupplejackApi::Fragment
      include SupplejackApi::Concerns::RecordFragmentable
    end
  end
end

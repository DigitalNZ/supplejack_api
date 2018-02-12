require 'spec_helper'

module SupplejackApi
  describe ApplicationHelper do

    def label(string)
      safe_join([string, content_tag(:span)])
    end

    describe '#extract_sort_info' do
      it 'returns the column and direction from the order param' do
        allow(helper).to receive(:params) { {order: 'name_asc'} }
        expect(helper.extract_sort_info).to eq ['name', 'asc']
      end
    end
  end
end

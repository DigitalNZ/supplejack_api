# frozen_string_literal: true

require 'spec_helper'

describe SupplejackApi::ApplicationHelper do
  def label(string)
    safe_join([string, tag(:span)])
  end

  describe '#extract_sort_info' do
    it 'returns the column and direction from the order param' do
      allow(helper).to receive(:params) { { order: 'name_asc' } }
      expect(helper.extract_sort_info).to eq %w[name asc]
    end
  end
end

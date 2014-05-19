require 'spec_helper'

module SupplejackApi
  describe ApplicationHelper do

    def label(string)
      safe_join([string, content_tag(:span)])
    end
    
    describe '#extract_sort_info' do
      it 'returns the column and direction from the order param' do
        helper.stub(:params) { {order: 'name_asc'} }
        helper.extract_sort_info.should eq ['name', 'asc']
      end
    end

    describe '#sortable' do
      pending
      # it 'returns a link to sort by name' do
      #   helper.sortable('user', 'name').should eq(link_to(label('Name'), admin_users_path(order: 'name_asc')))
      # end

      # context 'already ordered by name' do
      #   before { helper.stub(:params) { {order: 'name_asc'} }}

      #   it 'sorts by name in descending order' do
      #     helper.sortable('user', 'name').should eq(link_to(label('Name'), admin_users_path(order: 'name_desc'), class: 'current asc'))
      #   end

      #   it 'sorts by email in ascending order' do
      #     helper.sortable('user', 'email').should eq(link_to(label('Email'), admin_users_path(order: 'email_asc')))
      #   end
      # end
    end
  end
end
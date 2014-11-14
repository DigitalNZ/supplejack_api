# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government,
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details.
#
# Supplejack was created by DigitalNZ at the National Library of NZ and
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

describe 'Sets routes', type: :routing do
  routes { SupplejackApi::Engine.routes }

  it 'routes /sets.format to user_sets#index' do
    { get: '/sets.json' }.should route_to(controller: 'supplejack_api/user_sets', action: 'index', format: 'json')
  end

  it 'routes /users/123/sets.format to user_sets#index' do
    { get: '/users/123/sets.json' }.should route_to(controller: 'supplejack_api/user_sets', action: 'admin_index', format: 'json', user_id: '123')
  end

  it 'routes /sets/public.format to user_sets#public_index' do
    { get: '/sets/public.json' }.should route_to(controller: 'supplejack_api/user_sets', action: 'public_index', format: 'json')
  end

  it 'routes /sets/1.format to user_sets#show' do
    { get: '/sets/10.json' }.should route_to(controller: 'supplejack_api/user_sets', action: 'show', format: 'json', id: '10')
  end

  it 'routes /sets.format to user_sets#create' do
    {post: '/sets.json' }.should route_to(controller: 'supplejack_api/user_sets', action: 'create', format: 'json')
  end

  it 'routes /sets/123abc.json to user_sets#update' do
    { put: '/sets/123abc.json' }.should route_to(controller: 'supplejack_api/user_sets', action: 'update', format: 'json', id: '123abc')
  end

  it 'routes /sets/123abc/records.json to set_items#create' do
    { post: '/sets/123abc/records.json' }.should route_to(controller: 'supplejack_api/set_items', action: 'create', format: 'json', user_set_id: '123abc')
  end

  it 'routes /sets/123abc/records/666.json to set_items#destroy' do
    { delete: '/sets/123abc/records/666.json' }.should route_to(controller: 'supplejack_api/set_items', action: 'destroy', format: 'json', user_set_id: '123abc', id: '666')
  end
end

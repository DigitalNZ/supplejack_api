# frozen_string_literal: true

require 'spec_helper'

describe 'Sets routes', type: :routing do
  routes { SupplejackApi::Engine.routes }

  it 'routes /sets.format to user_sets#index' do
    expect({ get: '/sets.json' })
      .to route_to(controller: 'supplejack_api/user_sets', action: 'index', format: 'json', version: nil)
  end

  it 'routes /users/123/sets.format to user_sets#index' do
    expect({ get: '/users/123/sets.json' })
      .to route_to(controller: 'supplejack_api/user_sets',
                   action: 'admin_index',
                   format: 'json',
                   version: nil,
                   user_id: '123')
  end

  it 'routes /sets/public.format to user_sets#public_index' do
    expect({ get: '/sets/public.json' })
      .to route_to(controller: 'supplejack_api/user_sets',
                   action: 'public_index', format: 'json', version: nil)
  end

  it 'routes /sets/1.format to user_sets#show' do
    expect({ get: '/sets/10.json' })
      .to route_to(controller: 'supplejack_api/user_sets',
                   action: 'show', format: 'json', version: nil, id: '10')
  end

  it 'routes /sets.format to user_sets#create' do
    expect({ post: '/sets.json' })
      .to route_to(controller: 'supplejack_api/user_sets',
                   action: 'create', format: 'json', version: nil)
  end

  it 'routes /sets/123abc.json to user_sets#update' do
    expect({ put: '/sets/123abc.json' })
      .to route_to(controller: 'supplejack_api/user_sets',
                   action: 'update', format: 'json', version: nil, id: '123abc')
  end

  it 'routes /sets/123abc/records.json to set_items#create' do
    expect({ post: '/sets/123abc/records.json' })
      .to route_to(controller: 'supplejack_api/set_items',
                   action: 'create', format: 'json', version: nil, user_set_id: '123abc')
  end

  it 'routes /sets/123abc/records/666.json to set_items#destroy' do
    expect({ delete: '/sets/123abc/records/666.json' })
      .to route_to(controller: 'supplejack_api/set_items',
                   action: 'destroy', format: 'json', version: nil, user_set_id: '123abc', id: '666')
  end
end

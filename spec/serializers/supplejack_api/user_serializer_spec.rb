# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require 'spec_helper'

module SupplejackApi
  describe UserSerializer do
    let(:user) { User.new(name: 'Fed', email: 'fed@boost.com', username: 'fede', authentication_token: '12345') }
    let(:serializer) { UserSerializer.new(user) }
  
    it 'includes the basic user information' do
      user.stub(:id) { 'abc1234567' }
      serializer.as_json.should eq({user: {id: 'abc1234567', name: 'Fed', email: 'fed@boost.com', username: 'fede', api_key: '12345'}})
    end
  
  end

end

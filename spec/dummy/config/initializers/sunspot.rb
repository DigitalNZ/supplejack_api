# The majority of the Supplejack API code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# One component is a third party component. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

Sunspot.session = Sunspot::ResqueSessionProxy.new(Sunspot.session) unless Rails.env.test?

OriginalDismax = Sunspot::Query::Dismax

api_gem_dir = Gem::Specification.find_by_name("supplejack_api").gem_dir
require "#{api_gem_dir}/lib/sunspot/sunspot_spellcheck"

class PatchedDismax < OriginalDismax

  def to_params
    params = super
    params[:defType] = 'edismax'
    params
  end

  def to_subquery
    query = super
    query = query.sub '{!dismax', '{!edismax'
    query
  end

end

Sunspot::Query.send :remove_const, :Dismax
Sunspot::Query::Dismax = PatchedDismax
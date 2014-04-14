Sunspot.session = Sunspot::ResqueSessionProxy.new(Sunspot.session) unless Rails.env.test?

OriginalDismax = Sunspot::Query::Dismax

require_relative "../../lib/sunspot/sunspot_spellcheck"

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
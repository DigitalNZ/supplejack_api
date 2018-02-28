

Sunspot.session = Sunspot::SidekiqSessionProxy.new(Sunspot.session) unless Rails.env.test?

OriginalDismax = Sunspot::Query::Dismax

api_gem_dir = Gem::Specification.find_by_name("supplejack_api").gem_dir

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

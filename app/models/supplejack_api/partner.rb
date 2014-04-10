module SupplejackApi
  class Partner
    include Mongoid::Document
    
    store_in collection: 'partners', session: 'strong'
  
    attr_accessible :_id, :name
  
    field :name, type: String
  
    has_many :sources, class_name: 'SupplejackApi::Source'
  
    validates :name, presence: true
  end
end
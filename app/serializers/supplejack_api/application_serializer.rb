module SupplejackApi
  class ApplicationSerializer < ActiveModel::Serializer
    
    Schema.groups.keys.each do |group|
      define_method("#{group}?") do
        return false unless options[:groups].try(:any?)
        self.options[:groups].include?(group)  
      end
    end
  end

end

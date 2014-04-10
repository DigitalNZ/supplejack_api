require 'spec_helper'

module SupplejackApi
  describe Search do
  	before(:each) do
      @search = Search.new
      Sunspot.session = SunspotMatchers::SunspotSessionSpy.new(Sunspot.session)
      @session = Sunspot.session
    end
  end

end

require "spec_helper"

module SupplejackApi
  describe Partner do
    describe "validations" do
      it "is not valid without a name" do
        partner = Partner.new()
        partner.valid?.should be_false
      end
    end
  end

end
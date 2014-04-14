require 'spec_helper'

module SupplejackApi
  describe ApiRecord::Searchable do
    let(:record) { FactoryGirl.create(:record, record_id: 1234) }
    let(:fragment) { record.fragments.create({nz_citizen: false }) }
  
  
    describe "build_sunspot_schema" do
      let(:builder) { double(:search_builder).as_null_object }
      let(:search_value) { double(:proc) }
      before do
        Schema.stub(:fields) do
          {
            title: double(:field, name: :title, type: :string, search_as: [:filter]).as_null_object,
            count: double(:field, name: :count, type: :integer, search_as: [:filter]).as_null_object,
            date: double(:field, name: :date, type: :datetime, search_as: [:filter]).as_null_object,
            is_available: double(:field, name: :is_available, type: :boolean, search_as: [:filter]).as_null_object,
            collection: double(:field, name: :collection, type: :string, multi_value: true, search_as: [:filter]).as_null_object,
            text: double(:field, name: :text, type: :string, search_as: [:filter], solr_name: :new_name).as_null_object,
            description: double(:field, name: :description, type: :string, search_as: [:fulltext]).as_null_object,
            location: double(:field, name: :location, type: :string, search_as: [:fulltext], search_boost: 10).as_null_object,
            subject: double(:field, name: :subject, multi_value: true, type: :string, search_as: [:fulltext, :filter], search_boost: 2).as_null_object,
            sort_date: double(:field, name: :sort_date, type: :string, search_as: [:fulltext, :filter], search_value: search_value).as_null_object
          }
        end
      end
  
      after do
        Record.build_sunspot_schema(builder)
      end
  
      it "defines a single value string field" do
        builder.should_receive(:string).with(:title, {})
      end
  
      it "defines a single value integer field" do
        builder.should_receive(:integer).with(:count, {})
      end
  
      it "defines a single value time field" do
        builder.should_receive(:time).with(:date, {})
      end
  
      it "defines a single value boolean field" do
        builder.should_receive(:boolean).with(:is_available, {})
      end
  
      it "defines a multivalue field" do
        builder.should_receive(:string).with(:collection, {multiple: true})
      end
  
      it "defines a field with a different name" do
        builder.should_receive(:string).with(:text, {as: :new_name})
      end
  
      it "defines a full text field" do
        builder.should_receive(:text).with(:description, {})
      end
  
      it "defines a full text field with boost" do
        builder.should_receive(:text).with(:location, {boost: 10})
      end   
  
      it "defines a field with fulltext and filter, and lots of options" do
        builder.should_receive(:text).with(:subject, {boost: 2})
        builder.should_receive(:string).with(:subject, {multiple: true})
      end
    end

    describe "valid_facets" do
      it "returns all fields with search_as filter" do
        Record.valid_facets.should eq [:name, :address, :email, :nz_citizen, :birthdate]
      end      
    end
  
    # describe "calculate_boost" do
    #   before(:each) do
    #     Record.stub(:problematic_partners) { ["Bad partner", "PhotoSales"] }
    #   end
      
    #   it "returns 0.01 when content_partner is a problematic partner" do
    #     fragment.content_partner = ["Bad partner"]
    #     record.save
    #     record.calculate_boost.should eq 0.05
    #   end
  
    #   it "returns 1.1 when content_partner is not problematic" do
    #     fragment.content_partner = ["Tapuhi"]
    #     record.save
    #     record.calculate_boost.should eq 1.1
    #   end
  
    #   it "returns 1 when is_catalog_records == true" do
    #     fragment.is_catalog_record = true
    #     record.save
    #     record.calculate_boost.should eq 1
    #   end
  
    #   it "handles when content_partner is nil" do
    #     fragment.content_partner = nil
    #     record.save
    #     record.calculate_boost.should eq 1.1
    #   end
    # end
    
    # describe "#solr_dates" do
      # it "converts string dates to actual date objects" do
      #   fragment.date = ["2010-10-10", "2011-10-10"]
      #   record.save
      #   record.solr_dates.should eq([Date.parse("2010-10-10").to_time, Date.parse("2011-10-10").to_time])
      # end
      
      # it "discards an empty dates array" do
      #   fragment.date = nil
      #   record.save
      #   record.solr_dates.should eq([])
      # end
      
      # it "should discard invalid dates" do
      #   fragment.date = ["2010-10-10", "2011-20-20"]
      #   record.save
      #   record.solr_dates.should eq([Date.parse("2010-10-10").to_time])
      # end
    # end
    
  end

end

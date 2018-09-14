require 'spec_helper'
require 'generator_spec'

module SupplejackApi
  module Generators
    describe InstallGenerator, type: :generator do
      destination_path = File.expand_path("../tmp/", __FILE__)
      generator_files_path = File.expand_path(Rails.root)
      destination(destination_path)

      before(:all) do
        prepare_destination
        run_generator
      end

      describe '#config files' do
        let(:generated_application_yml) { File.read("#{destination_path}/config/application.yml") }
        let(:generated_schedule) { File.read("#{destination_path}/config/schedule.rb") }
        let(:example_schedule) { File.read("#{generator_files_path}/config/schedule.example.rb")}

        it 'adds details to application.yml' do
          File.open("#{generator_files_path}/config/application.yml.example").each do |line|
            expect(generated_application_yml).to include line
          end
        end

        it 'adds details to schedule.rb' do
          expect(generated_schedule).to include example_schedule
        end

        it 'creates mongoid.yml' do
          assert_file("#{destination_path}/config/mongoid.yml")
        end

        it 'creates sunspot.yml' do
          assert_file("#{destination_path}/config/sunspot.yml")
        end
      end
    end
  end
end

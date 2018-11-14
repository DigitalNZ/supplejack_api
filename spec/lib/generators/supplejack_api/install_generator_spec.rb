require 'spec_helper'
require 'generator_spec'

module SupplejackApi
  module Generators
    describe InstallGenerator, type: :generator do
      destination_path = File.expand_path("../tmp/", __FILE__)
      generator_files_path = File.expand_path(Rails.root)
      destination(destination_path)

      before(:all) do
        # Generate fake Gemfile, routes
        prepare_destination
        system "mkdir -p #{destination_path}/config"
        system "echo end >> #{destination_path}/config/routes.rb"
        system "echo 'gem \'supplejack_api\'' >> #{destination_path}/Gemfile"
        run_generator
      end

      after(:all) do
        system "rm -rf #{destination_path}"
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

      describe '#initializers' do
        it 'creates devise.rb' do
          assert_file "#{destination_path}/config/initializers/devise.rb"
        end
        it 'creates kaminari_config.rb' do
          assert_file "#{destination_path}/config/initializers/kaminari_config.rb"
        end
        it 'creates quiet_logger.rb' do
          assert_file "#{destination_path}/config/initializers/quiet_logger.rb"
        end
        it 'creates sidekiq.rb' do
          assert_file "#{destination_path}/config/initializers/sidekiq.rb"
        end
        it 'creates state_machine.rb' do
          assert_file "#{destination_path}/config/initializers/state_machine.rb"
        end
        it 'creates sunspot.rb' do
          assert_file "#{destination_path}/config/initializers/sunspot.rb"
        end
        it 'creates supplejack_api.rb' do
          assert_file "#{destination_path}/config/initializers/supplejack_api.rb"
        end
        it 'creates mongoid.rb' do
          assert_file "#{destination_path}/config/initializers/mongoid.rb"
        end
        it 'creates interaction_updaters.rb' do
          assert_file "#{destination_path}/config/initializers/interaction_updaters.rb"
        end
        it 'creates force_eagerload.rb' do
          assert_file "#{destination_path}/config/initializers/force_eagerload.rb"
        end
      end

      describe '#mount_engine' do
        it 'mounts the supplejac routes' do
          expect(File.read("#{destination_path}/config/routes.rb")).to include 'mount SupplejackApi::Engine => \'/\', as: \'supplejack_api\''
        end
      end

      describe '#update_gemfile' do
        let(:gemfile) { File.read("#{destination_path}/Gemfile") }

        it 'adds the required gems to the gemfile' do
          expect(gemfile).to include "gem 'sunspot_rails', '~> 2.2.0'"
          expect(gemfile).to include "gem 'active_model_serializers', '~> 0.10.7'"
          expect(gemfile).to include "gem 'mongoid_auto_increment'"
          expect(gemfile).to include "gem 'whenever', '~> 0.10.0'"
        end
      end

      describe '#create_schema' do
        it 'creates the record_schema.rb' do
          assert_file "#{destination_path}/app/supplejack_api/record_schema.rb"
        end

        it 'creates the concepts_schema.rb' do
          assert_file "#{destination_path}/app/supplejack_api/concept_schema.rb"
        end
      end
    end
  end
end

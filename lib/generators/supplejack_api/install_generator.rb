

require 'rails/generators'

module SupplejackApi
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc 'Used to install SupplejackApi'
      class_option :documentation, type: :boolean, default: true, desc: 'Displays documentation after installation'

      source_root(File.expand_path('../../../../spec/dummy/', __FILE__))

      def config_files
        puts "\nInstalling config files into config/"

        copy_file('config/application.yml.example', 'config/application.yml')
        copy_file('config/schedule.example.rb', 'config/schedule.rb')
        copy_file 'config/mongoid.yml'
        copy_file 'config/sunspot.yml'

        puts "\nGenerating secret token"

        inject_into_file('config/application.yml', before: /^\sdevelopment:/) do
          "  SECRET_TOKEN: '#{Digest::SHA1.hexdigest([Time.now, rand].join)}'\n"
        end
      end

      def workers
        directory 'app/workers'
      end

      def initializers
        puts "\nInstalling initializers into config/initializers/"

        copy_file 'config/initializers/devise.rb'
        copy_file 'config/initializers/kaminari_config.rb'
        copy_file 'config/initializers/quiet_logger.rb'
        copy_file 'config/initializers/sidekiq.rb'
        copy_file 'config/initializers/simple_form.rb'
        copy_file 'config/initializers/simple_form_foundation.rb'
        copy_file 'config/initializers/state_machine.rb'
        copy_file 'config/initializers/sunspot.rb'
        copy_file 'config/initializers/supplejack_api.rb'
        copy_file 'config/initializers/mongoid.rb'
        copy_file 'config/initializers/interaction_updaters.rb'
        copy_file 'config/initializers/force_eagerload.rb'
        directory 'config/locales'
      end

      def environment_files
        puts "\nInstalling environment files into config/environments/"

        copy_file 'config/environments/production.rb'
        gsub_file('config/environments/production.rb', 'Dummy::Application', Rails.application.class.to_s)
      end

      def mount_engine
        puts "\nMounting SupplejackApi::Engine at / in config/routes.rb"

        inject_into_file('config/routes.rb', "\n  mount SupplejackApi::Engine => '/', as: 'supplejack_api'\n\n", :before => /^end/)
      end

      def update_gemfile
        puts "\nAdding dependencies into Gemfile"

        inject_into_file('Gemfile', after: /^gem.*supplejack_api.*/) do
          string = [""]
          string << "gem 'sunspot_rails', '~> 2.2.0'"
          string << "gem 'active_model_serializers', '~> 0.10.7'"
          string << "gem 'mongoid_auto_increment'"

          string << "gem 'whenever', '~> 0.10.0'"

          string.join("\n")
        end
      end

      def create_schema
        puts "\nCreating Default Record Schemas in app/supplejack_api/"
        empty_directory 'app/supplejack_api'
        copy_file 'app/supplejack_api/record_schema.txt','app/supplejack_api/record_schema.rb'
        copy_file 'app/supplejack_api/concept_schema.rb'
      end

      def add_assets
        puts "\nAdding assets "
        insert_into_file "app/assets/javascripts/application.js", "//= require highcharts/highcharts\n", :after => "rails-ujs\n"
        insert_into_file "app/assets/javascripts/application.js", "//= require highcharts/highcharts-more\n", :after => "rails-ujs\n"
        insert_into_file "app/assets/javascripts/application.js", "//= require highcharts/highstock\n", :after => "rails-ujs\n"
        insert_into_file "app/assets/stylesheets/application.css", "\n *= require supplejack_api/application", :after => "require_self"
      end

      def documentation
        if options.documentation?
          string = []
          string << 'Welcome to Supplejack API.'
          string << "Installation process is complete.\n"
          string << 'In order to have have a working API, follow the steps below:'
          string << '1. Implement your data schema in app/supplejack_api/schema.rb. See comments for DSL documentation'
          string << '2. Edit config/application.yml and set all the keys to the correct values for your environments'
          string << "3. Start Solr via via `bundle exec rake sunspot:solr:start|stop`. Ensure it's working by going to http://localhost:8983/solr/, you should see the Solr dashboard"
          string << "4. Start the rails console via `bundle exec rails console`. Perform the next commands in the rails console"
          string << "5. Use a local Solr session so updates are immediate via `Sunspot.session = Sunspot::Rails.build_session`"
          string << "6. Create a user via `user = SupplejackApi::User.create(email: 'test@example.com', name: 'Test User')`"
          string << "7. Create a record via `record = SupplejackApi.config.record_class.create(internal_identifier: 'abc123', status: 'active', source_url: 'http://boost.co.nz/')`"
          string << "8. Add your custom data (from schema.rb) to the record's primary fragment via `record.primary_fragment.<field_name>=<value>`. Then `record.save!`"
          string << "9. Start the rails server via `bundle exec rails server -p 3000`"
          string << "10. Retrieve a specific record by going to http://localhost:3000/records/<record.record_id>.json?api_key=<user.api_key>"
          string << "11. Perform a search by going to http://localhost:3000/records.json?api_key=<user.api_key>"
          string << "12. You now have a working API!"

          puts string.join("\n")
        end
      end

      def finished
        puts 'supplejack_api generator install is complete'
      end
    end
  end
end

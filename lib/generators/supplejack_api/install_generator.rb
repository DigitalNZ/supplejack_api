require 'rails/generators'

module SupplejackApi
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc 'Used to install SupplejackApi'

      source_root(File.expand_path('../../../../spec/dummy/', __FILE__))

      def initializers
        puts "\nInstalling initializers into config/initializers/"

        copy_file 'config/initializers/devise.rb'
        copy_file 'config/initializers/kaminari_config.rb'
        copy_file 'config/initializers/quiet_logger.rb'
        copy_file 'config/initializers/resque.rb'
        copy_file 'config/initializers/simple_form.rb'
        copy_file 'config/initializers/simple_form_foundation.rb'
        copy_file 'config/initializers/state_machine.rb'
        copy_file 'config/initializers/status_logger.rb'

        directory 'config/locales'
      end

      def config_files
        puts "\nInstalling config files into config/"

        copy_file('config/application.yml.example', 'config/application.yml')
        copy_file 'config/mongoid.yml'
        copy_file 'config/resque-pool.yml'
        copy_file 'config/resque_schedule.yml'
        copy_file 'config/sunspot.yml'

        puts "\nGenerating secret token"

        inject_into_file('config/application.yml', before: /^\sdevelopment:/) do
          "  SECRET_TOKEN: '#{Digest::SHA1.hexdigest([Time.now, rand].join)}'\n"
        end
      end

      def environment_files
        puts "\nInstalling environment files into config/environments/"

        copy_file 'config/environments/production.rb'
        gsub_file('config/environments/production.rb', 'Dummy::Application', Rails.application.class.to_s)
      end

      def solr_config_files
        puts "\nInstalling Solr config files into solr/"

        directory 'solr'
      end

      def mount_engine
        puts "\nMounting SupplejackApi::Engine at / in config/routes.rb"

        inject_into_file('config/routes.rb', "\n  mount SupplejackApi::Engine => '/', as: 'supplejack_api'\n\n", :before => /^end/)
      end

      def update_gemfile
        puts "\nAdding dependencies into Gemfile"

        inject_into_file('Gemfile', after: /^gem.*supplejack_api.*/) do
          string = [""]
          string << "gem 'active_model_serializers', git: 'https://github.com/boost/active_model_serializers.git'"
          string << "gem 'mongoid_auto_inc', git: 'https://github.com/boost/mongoid_auto_inc.git'"

          string.join("\n")
        end
      end

      def create_schema
        puts "\nCreating Schema in app/supplejack_api/schema.rb"

        empty_directory 'app/supplejack_api'
        copy_file 'app/supplejack_api/schema.rb'
      end

      def documentation
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
        string << "7. Create a record via `record = SupplejackApi::Record.create(internal_identifier: 'abc123', status: 'active', landing_url: 'http://boost.co.nz/')`"
        string << "8. Add your custom data (from schema.rb) to the record's primary fragment via `record.primary_fragment.<field_name>=<value>`. Then `record.save!`"
        string << "9. Start the rails server via `bundle exec rails server -p 3000`"
        string << "10. Retrieve a specific record by going to http://localhost:3000/records/<record.record_id>.json?api_key=<user.api_key>"
        string << "11. Perform a search by going to http://localhost:3000/records.json?api_key=<user.api_key>"
        string << "12. You now have a working API!"

        puts string.join("\n")
      end
    end
  end
end
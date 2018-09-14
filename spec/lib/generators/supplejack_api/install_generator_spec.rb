require 'spec_helper'
require 'generator_spec'

module SupplejackApi
  module Generators
    describe InstallGenerator, type: :generator do
      destination File.expand_path("../tmp/", __FILE__)

      before(:all) do
        prepare_destination
        run_generator
      end

      describe '#config files' do
        let(:generated_application_yml) { File.read(destination)}
        it 'adds details to application yml' do
          binding.pry
          expect(true).to be true
        end
      end
    end
  end
end

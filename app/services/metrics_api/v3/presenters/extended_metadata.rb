module MetricsApi
  module V3
    module Presenters
      class ExtendedMetadata
        attr_reader :models

        def initialize(metric_models)
          @models = metric_models
        end

        def to_json
          
        end

        def self.to_proc
          ->(models){self.new(models).to_json}
        end
      end
    end
  end
end

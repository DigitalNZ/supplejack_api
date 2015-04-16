module SupplejackApi
  module ApiRecord
    module LinkCheckable
      extend ActiveSupport::Concern

      def link_check
        begin
          if self.landing_url.present?
            link_check_data = { url: self.landing_url, record_id: self.record_id, source_id: self.primary_fragment.source_id }
            RestClient.post("#{ENV['WORKER_API_URL']}/link_check_jobs", { link_check: link_check_data })
          end
        rescue Exception => e
          Rails.logger.warn("There was a unexpected error when trying to POST to #{ENV['WORKER_API_URL']}/link_check_jobs to link check record ID: #{record_id}")
          Rails.logger.warn("Exception: #{e.inspect}")
        end
      end
    end
  end
end
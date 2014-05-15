# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

 module SupplejackApi
  class FlushOldRecordsWorker

    @queue = :flush_records

    def self.perform(source_id, job_id)
      Record.flush_old_records(source_id, job_id)
    end
  end
end
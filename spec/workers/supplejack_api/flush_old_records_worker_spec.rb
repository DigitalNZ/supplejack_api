# The majority of the Supplejack code is Crown copyright (C) 2014, New Zealand Government, 
# and is licensed under the GNU General Public License, version 3.
# Some components are third party components licensed under the GPL or MIT licenses 
# or otherwise publicly available. See https://github.com/DigitalNZ/supplejack_api for details. 
# 
# Supplejack was created by DigitalNZ at the National Library of NZ and 
# the Department of Internal Affairs. http://digitalnz.org/supplejack

require "spec_helper"

module SupplejackApi
  describe FlushOldRecordsWorker do

    describe "perform" do
      it "should call 'flush_old_records' on Record with the given source_id & job_id" do
        Record.should_receive(:flush_old_records).with("abc-123", "abc123")
        FlushOldRecordsWorker.perform("abc-123", "abc123")
      end
    end
  end
end
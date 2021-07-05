# frozen_string_literal: true

require 'spec_helper'

module SupplejackApi
  describe StoreUserActivityWorker do
    let!(:users) { create_list(:user, 10, daily_activity_stored: false) }
    before do
      # Generating some daily metrics
      users.each do |user|
        user.daily_activity = {
          records: {
            show: 2449
          },
          stories: {
            show: 522,
            admin_index: 157,
            update: 48
          },
          search: {
            records: 1185
          },
          concepts: {
            show: 3
          },
          user_sets: {
            create_item: 15,
            destroy_item: 9,
            update_item: 9
          }
        }
        user.save!
      end
    end

    it 'successfuly reset daily activity' do
      users.each do |user|
        expect(user.daily_activity).not_to be_nil
      end

      subject.perform
      users.each do |user|
        user.reload
        expect(user.daily_activity).to be_nil
        expect(user.daily_activity_stored).to be_truthy
      end
    end

    it 'logs an error when failed to reset daily activities and raise error' do
      allow_any_instance_of(SupplejackApi::User).to receive(:save!).and_raise(StandardError)
      expect(Rails.logger).to receive(:error).exactly(2).times

      expect { subject.perform }.to raise_error(StandardError)
    end

    it 'logs a warn when reset daily activity job is called on user more than once a day' do
      user = users.first
      user.daily_activity_stored = true
      user.save!
      expect(Rails.logger).to receive(:warn).exactly(1).times
      subject.perform
    end

    it 'logs as error when generate_activity raise an exception and raise error' do
      allow(SupplejackApi::SiteActivity).to receive(:generate_activity).and_raise(StandardError)
      expect(Rails.logger).to receive(:error).exactly(1).times

      expect { subject.perform }.to raise_error(StandardError)
    end
  end
end

require 'rails_helper'

RSpec.describe ResetRemainingBudgetJob, type: :job do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe '#perform' do
    it 'enqueues the job' do
      expect { ResetRemainingBudgetJob.perform_later }.to have_enqueued_job(ResetRemainingBudgetJob).on_queue('default')
    end

    it 'calls the User.reset_all_remaining_budgets method' do
      expect(User).to receive(:reset_all_remaining_budgets)
      ResetRemainingBudgetJob.perform_now
    end
  end
end

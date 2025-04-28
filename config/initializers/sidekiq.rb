redis_url = ENV.fetch('REDIS_URL') { 'redis://localhost:6379/0' }

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }
end

Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

require 'sidekiq-cron'

Sidekiq::Cron::Job.create(
  name: 'Reset User Remaining Budgets - Every month',
  cron: '0 0 1 * *',
  class: 'ResetRemainingBudgetJob'
)

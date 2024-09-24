Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://localhost:6379/0' }
end

require 'sidekiq-cron'

Sidekiq::Cron::Job.create(
  name: 'Reset User Budgets - Every month',
  cron: '0 0 1 * *',
  class: 'ResetBudgetJob'
)

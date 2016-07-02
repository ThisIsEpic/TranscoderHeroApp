Sidekiq.configure_server do |config|
  config.redis = { url: 'redis://127.0.0.1:7372/12' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: 'redis://127.0.0.1:7372/12' }
end

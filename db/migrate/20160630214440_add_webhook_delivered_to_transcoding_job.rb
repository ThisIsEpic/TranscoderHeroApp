class AddWebhookDeliveredToTranscodingJob < ActiveRecord::Migration[5.0]
  def change
    add_column :transcoding_jobs, :webhook_delivered, :boolean, default: false
    add_column :transcoding_jobs, :last_webhook_sent_at, :datetime
    add_column :transcoding_jobs, :webhook_delivery_retries, :integer, default: 0
    add_column :transcoding_jobs, :webhook_url, :string
  end
end

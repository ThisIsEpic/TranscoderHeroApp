class JobSuccessWebhookJob < ApplicationJob
  queue_as :default

  def perform(job)
    @job = job

    puts "Sending webhook for job #{@job.id}"
    now = Time.now
    response = RestClient.post(@job.webhook_url, job: @job.to_json)

    if response.code == 200
      @job.update(
        last_webhook_sent_at: now,
        webhook_delivered: true
      )
    else
      @job.update(
        last_webhook_sent_at: now,
        webhook_delivery_retries: @job.webhook_delivery_retries + 1
      )
      raise FailedWebhookError
    end
  end

  class FailedWebhookError; end
end

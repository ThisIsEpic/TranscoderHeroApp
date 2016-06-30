class TranscodingJob < ApplicationRecord
  include AASM

  belongs_to :app

  validates :input, presence: true, url: true
  validates :webhook_url, presence: true, url: true

  after_create :enqueue_job

  enum state: %i(created processing completed failed)

  aasm column: :state, enum: true do
    state :created, initial: true
    state :processing
    state :completed
    state :failed
    state :pending

    event :process do
      transitions from: :created, to: :processing
    end

    event :complete, after_commit: :send_success_webhook do
      transitions from: :processing, to: :completed
    end

    event :fail do
      transitions from: :processing, to: :failed
    end
  end

  def local_pathname
    token = [app.id, id, created_at, input].join('/')
    Digest::MD5.hexdigest(token)
  end

  private

  def send_success_webhook
    return unless completed?
    JobSuccessWebhookJob.perform_later(self)
  end

  def enqueue_job
    return if completed?
    ProcessTranscodingJob.perform_later(self)
  end
end

class TranscodingJob < ApplicationRecord
  include AASM
  
  belongs_to :app

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

    event :complete do
      transitions from: :processing, to: :completed
    end

    event :fail do
      transitions from: :processing, to: :failed
    end
  end

  private

  def enqueue_job
    ProcessTranscodingJob.perform_later(self)
  end
end

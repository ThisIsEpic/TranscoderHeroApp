class ProcessTranscodingJob < ApplicationJob
  queue_as :default

  def perform(job)
    return true unless job
    TranscodingJobManager.new(job).process! if job.created?
  end
end

class ProcessTranscodingJob < ApplicationJob
  queue_as :default

  def perform(job)
    TranscodingJobManager.new(job).process! if job.created?
  end
end

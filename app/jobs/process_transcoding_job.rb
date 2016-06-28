class ProcessTranscodingJob < ApplicationJob
  queue_as :default

  def perform(job)
    # Connect to s3 and download video
    RemoteFileManager.new(job.input)
  end
end

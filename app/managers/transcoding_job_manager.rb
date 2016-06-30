class TranscodingJobManager
  def initialize(transcoding_job)
    @job = transcoding_job
    @app = transcoding_job.app
    @rfm = RemoteFileManager.new(@job.input)
    @download_path = [Rails.root, 'public/system/inputs', @app.id, @job.local_pathname].join('/')
  end

  def process!
    @job.process! if @job.created?
    download_file
    transcode_file
    upload_products
    @job.complete!
  end

  def download_file
    @local_file = @rfm.download!(@download_path)
  end

  def upload_products
  end

  def transcode_file
    puts %x(`ffmpeg -i #{@download_path}`)
  end
end

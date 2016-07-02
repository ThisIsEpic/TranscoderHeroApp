require 'open3'

class TranscodingJobManager
  attr_reader :encoded

  def initialize(transcoding_job)
    @job = transcoding_job
    @app = transcoding_job.app
    @rfm = RemoteFileManager.new(@job.input)
    @upload_manager = JobUploaderManager.new(@app)
    @download_path = [Rails.root, 'public/system/inputs', @app.id, @job.local_pathname].join('/')
    @output_dir = "#{Rails.root}/public/system/outputs/#{@app.id}/#{@job.id}"
    @remote_path = Digest::MD5.hexdigest([@app.id, @job.id, @job.local_pathname].join('/'))
  end

  def process!
    @job.process! if @job.created?
    download_file
    transcode_file
    upload_products
    # @job.complete!
    remove_files_from_hard_drive
  end

  def download_file
    @local_file = @rfm.download!(@download_path)
  end

  def job_successful?
    File.exist?("#{@output_dir}/#{@job.local_pathname}")
  end

  def upload_products
    @upload_manager.upload_directory(@output_dir, @remote_path)
    if job_successful?

    else
      @job.fail!
    end
  end

  def remove_files_from_hard_drive
    # make sure all files have successfully been uploaded before we delete them
    if @job.completed?
      # Create Background Job
    end
  end

  def transcode_file
    FileUtils.mkdir_p("#{@output_dir}/frames")
    output_video = "-map '[out1]' -profile:v baseline -level 3.0 #{@output_dir}/#{@job.local_pathname}.mp4"
    output_frames = "-map '[out2]' -q:v 6 #{@output_dir}/frames/#{@job.local_pathname}_%03d.jpg"
    filters = "-filter_complex '[0] crop=1080:1080:420:0, scale=-2:600, split=2[out1][out2]'"
    command = "ffmpeg -y -i #{@download_path} #{filters} #{output_video} #{output_frames}"
    std_output = ''
    std_errors = ''
    Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
      std_output = stdout.read unless stdout.nil?
      std_errors = stderr.read unless stderr.nil?
    end

    @encoded = @valid = FFMPEG::Movie.new("#{@output_dir}/#{@job.local_pathname}.mp4")
  end
end

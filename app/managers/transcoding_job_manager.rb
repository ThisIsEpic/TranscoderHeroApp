require 'open3'

class TranscodingJobManager
  attr_reader :encoded, :output_bucket_url

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
    if upload_products
      @job.update! output_data: output_data
      @job.complete!
      remove_files_from_hard_drive
    end
  end

  def output_bucket_url
    @output_bucket_url ||= Aws::S3::Bucket.new(@app.s3_output_bucket, client: AppManager.new(@app).s3).url
  end

  def output_data
    base_path = "#{output_bucket_url}/#{@remote_path}"
    video_url = "#{base_path}/#{@job.local_pathname}.mp4"
    frame_basepath = "#{base_path}/frames/#{@job.local_pathname}"
    frames = Dir.glob("#{@output_dir}/frames/*.jpg")

     {
      video: video_url,
      frame_basepath: frame_basepath,
      frames_count: frames.size,
      base_url: base_path
    }
  end

  def download_file
    @local_file = @rfm.download!(@download_path)
  end

  def job_successful?
    File.exist?("#{@output_dir}/#{@job.local_pathname}.mp4")
  end

  def upload_products
    if job_successful?
      @upload_manager.upload_directory(@output_dir, @remote_path)
      return true
    end

    false
  end

  def remove_files_from_hard_drive
    # make sure all files have successfully been uploaded before we delete them
    if @job.completed?
      FileUtils.rm_rf([@output_dir, @download_path], secure: true)
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

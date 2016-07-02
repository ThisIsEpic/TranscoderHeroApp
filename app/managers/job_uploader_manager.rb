class JobUploaderManager
  attr_accessor :files

  def initialize(app)
    @app = app
    @s3_client = AppManager.new(@app)
    @bucket = Aws::S3::Bucket.new(@app.s3_output_bucket, client: @s3_client.s3)
  end

  def upload_directory(local_dir, remote_path)
    @files = Dir.glob("#{local_dir}/**/*")
    @total_files = files.length
    thread_count = 5

    file_number = 0
    mutex = Mutex.new
    threads = []

    thread_count.times do |i|
      threads[i] = Thread.new do
        until files.empty?
          mutex.synchronize do
            file_number += 1
            Thread.current['file_number'] = file_number
          end
          file = files.pop rescue nil
          next unless file

          path = file
          puts "[#{Thread.current['file_number']}/#{@total_files}] uploading..."

          data = File.open(file)
          next if File.directory?(data)

          basename = File.basename(path)
          key = if path =~ /frames\/#{basename}\Z/
                  "#{remote_path}/frames/#{basename}"
                else
                  "#{remote_path}/#{basename}"
                end
          @bucket.put_object(
            key: key,
            acl: 'public-read',
            body: data
          )
        end
      end
    end

    threads.each(&:join)
  end
end

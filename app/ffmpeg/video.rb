require 'Open3'

module FFMPEG
  class Video
    attr_reader :path, :duration, :time, :bitrate, :rotation, :video_stream,
                :video_codec, :video_bitrate, :colorspace, :width, :height,
                :sar, :dar, :frame_rate, :container

    def initialize(path)
      raise Errno::ENOENT, "#{path} does not exist" unless File.exist?(path)
      @path = path

      command = "ffprobe -i #{Shellwords.escape(@path)} -print_format json -show_format -show_streams -show_error"

      std_output = ''
      std_error = ''
      Open3.popen3(command) do |stdin, stdout, stderr|
        std_output = stdout.read unless stdout.nil?
        std_error = stderr.read unless stderr.nil?
      end

      meta = JSON.parse(std_output).with_indifferent_access

      video_streams = meta[:streams].select { |s| s[:codec_type] == 'video' }
      audio_streams = meta[:streams].select { |s| s[:codec_type] == 'audio' }

      @container = meta.dig(:format, :format_name)
      @duration = meta.dig(:format, :duration).to_f
      @time = meta.dig(:format, :start_time).to_f
      @bitrate = meta.dig(:format, :bit_rate).to_i

      unless video_streams.empty?
        video_stream = video_streams.first
        @video_codec = video_stream[:codec_name]
        @colorspace = video_stream[:pix_fmt]
        @width = video_stream[:width]
        @height = video_stream[:height]
        @video_bitrate = video_stream[:bit_rate].to_i
        @frame_rate = video_stream[:avg_frame_rate] == '0/0' ? Rational(video_stream[:avg_frame_rate]) : nil
        @video_profile = video_stream[:profile]
        @sar = video_stream[:sample_aspect_ratio]
        @dar = video_stream[:display_aspect_ratio]
        @video_stream = "#{@video_codec} (#{@video_profile}) (#{video_stream[:codec_tag_string]} / #{video_stream[:codec_tag]}), #{@colorspace}, #{@resolution} [SAR #{@sar} DAR #{@dar}]"
        @rotation = video_stream.dig(:tags, :rotate).try(:to_i)
      end
    end

    def valid?
      ! @invalid
    end

    def width
      rotation.nil? || rotation == 180 ? @width : @height
    end

    def height
      rotation.nil? || rotation == 180 ? @height : @width
    end

    def resolution
      unless width.nil? || height.nil?
        "#{width}x#{height}"
      end
    end

    def size
      File.size(@path)
    end

    def calculated_aspec_ratio
      aspect_from_dar || aspect_from_dimensions
    end

    def calculated_pixel_aspect_ratio
      aspect_from_sar || 1
    end

    private

    def aspect_from_dar
      return nil unless @dar
      w, h = @dar.split(':')
      aspect = (@rotation.nil? || @rotation == 180) ? (w.to_f / h.to_f) : (h.to_f / w.to_f)
      aspect.zero? ? nil : aspect
    end

    def aspect_from_sar
      return nil unless @sar
      w, h = @sar.split(':')
      aspect = (@rotation.nil? || @rotation == 180) ? (w.to_f / h.to_f) : (h.to_f / w.to_f)
      aspect.zero? ? nil : aspect
    end

    def aspect_from_dimensions
      aspect = width.to_f / height.to_f
      aspect.nan? ? nil : aspect
    end
  end
end

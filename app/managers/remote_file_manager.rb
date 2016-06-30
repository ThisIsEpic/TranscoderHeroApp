require 'fileutils'
require 'open-uri'
require 'mime/types'

class RemoteFileManager
  def initialize(url)
    @uri = URI(url)
  end

  def file_header
    return @file_header if defined? @file_header
    request = Net::HTTP.new(@uri.host)
    @file_header = request.request_head(@uri.path)

    @file_header
  end

  def exists?
    file_header.code.to_i == 200
  end

  def video?
    return false unless exists?
    MIME::Types[/^video/].map(&:to_s).include? file_header['Content-Type']
  end

  def download!(local_path = nil)
    raise RemoteFileNonexistentError unless exists?
    raise UnsupportedFileTypeError unless video?
    raise 'Specify where to save the file' unless local_path

    FileUtils.mkdir_p(File.dirname(local_path))
    IO.copy_stream(open(@uri.to_s), local_path)

    File.exist?(local_path) ? File.new(local_path) : false
  end

  class UnsupportedFileTypeError < StandardError; end
  class RemoteFileNonexistentError < StandardError; end
end

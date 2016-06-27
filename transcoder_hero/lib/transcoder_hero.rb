require 'rest-client'
require 'transcoder_hero/version'
require 'transcoder_hero/job'

module TranscoderHero
  @base_uri = 'https://api.transcoder-hero.com/'

  class << self
    attr_accessor :api_key, :base_uri

    def headers
      { 'Authorization' => "Token token='#{@api_key}'" }
    end

    def request(method, path, payload = nil, headers = {})
      url = base_uri + path
      headers = headers.merge(headers)
      response = RestClient::Request.execute(
        method: method,
        url: url,
        payload: payload,
        headers: headers
      )

      JSON.parse response.body
    end
  end
end

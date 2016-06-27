module TranscoderHero
  class Job
    class << self
      def create(payload = {})
        TranscoderHero.request(:post, 'jobs', payload)
      end
    end
  end
end

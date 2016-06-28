class AppManager
  attr_accessor :s3

  def initialize(app)
    @app = app
    @s3 = Aws::S3::Client.new(
      region: 'us-west-1',
      access_key_id: @app.s3_access_key_id,
      secret_access_key: @app.s3_secret_access_key
    )
  end

  def create_bucket!
    response = @s3.create_bucket bucket: @app.s3_output_bucket
  end

  def put_cors_policy!
    response = @s3.put_bucket_cors(
      bucket: @app.s3_output_bucket,
      cors_configuration: {
        cors_rules: [
          allowed_headers: %w(
            Authorization Content-Type Content-Length x-amz-date origin
            Access-Control-Expose-Headers
          ),
          allowed_methods: %w(PUT GET),
          expose_headers: %w(Etag),
          allowed_origins: %w(transcoder-hero.com),
          max_age_seconds: 3000
        ]
      }
    )
  end
end

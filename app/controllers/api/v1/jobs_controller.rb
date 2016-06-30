class Api::V1::JobsController < Api::V1::BaseController
  skip_before_action :requires_authentication_token, only: %w(webhook)

  def index
  end

  def create
    job = current_app.jobs.new(job_params)
    if job.valid?
      job.save
      render json: {
        job: job
      }, status: :created
    else
      render json: {
        errors: job.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  def webhook
    puts JSON.parse(params[:job]).inspect
    head :ok
  end

  private

  def job_params
    params.require(:job).permit :input, :webhook_url, profiles: [], override: {}
  end
end

# TranscoderHero::Job.create(
#   input: 'https://s3.amazonaws.com/vdb-submit-media-staging/video/d7bf18225e7e92ed963115bae575ec26a2420e33.mov',
#   profiles: ['Virtual Diamond Resize', 'Virtual Diamond Crop', 'Extract Frames'],
#   override: {
#     crop: {
#       w: 1080,
#       h: 1080,
#       left: 420,
#       top: 0
#     },
#     scale: {
#       width: 600,
#       height: 600
#     }
#   }
# )

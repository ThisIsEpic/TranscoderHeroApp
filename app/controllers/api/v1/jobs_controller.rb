class Api::V1::JobsController < Api::V1::BaseController
  def index
  end

  def create
    puts params.inspect
    render json: 'No Content'
  end

  private

  def job_params
    params.require(:job).permit :input, profiles: [], override: {}
  end
end

TranscoderHero::Job.create(
  input: 'https://s3.amazonaws.com/vdb-submit-media-staging/video/d7bf18225e7e92ed963115bae575ec26a2420e33.mov',
  profiles: ['Virtual Diamond Resize', 'Virtual Diamond Crop', 'Extract Frames'],
  override: {
    crop: {
      w: 1080,
      h: 1080,
      left: 420,
      top: 0
    },
    scale: {
      width: 600,
      height: 600
    }
  }
)

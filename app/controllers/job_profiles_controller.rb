class JobProfilesController < ApplicationController
  before_action :load_app, only: %w(index)
  def index
    @profiles = @app.profiles
  end

  def new
    @profile = JobProfile.new
  end

  private

  def load_app
    @app = current_user.apps.find(params[:app_id])
  end
end

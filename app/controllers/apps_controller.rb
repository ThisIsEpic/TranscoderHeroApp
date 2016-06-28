class AppsController < ApplicationController
  before_action :load_app, only: %w(show edit update set_default)

  def index
    @apps = current_user.apps
  end

  def show
  end

  def new
    @app = App.new
  end

  def edit
  end

  def update
    if @app.update app_params
      redirect_to app_path(@app), notice: 'App updated successfully!'
    else
      render :edit
    end
  end

  def create
    @app = current_user.apps.new app_params

    if @app.valid?
      @app.save
      redirect_to apps_path, notice: 'App created successfully!'
    else
      render :edit
    end
  end

  private

  def load_app
    @app = current_user.apps.find(params[:id])
  end

  def app_params
    params.require(:app).permit :name, :url, :s3_access_key_id,
                                :s3_secret_access_key
  end
end

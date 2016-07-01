class WelcomeController < ApplicationController
  def index
    redirect_to dashboard_path if user_signed_in?
  end

  def dashboard
    @jobs = current_user.jobs
    @failed_jobs = @jobs.failed
    @completed_jobs = @jobs.completed
    @processing_jobs = @jobs.processing
  end
end

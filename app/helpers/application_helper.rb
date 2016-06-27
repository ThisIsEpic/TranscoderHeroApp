module ApplicationHelper
  def my_apps
    @apps ||= current_user.apps
  end
end

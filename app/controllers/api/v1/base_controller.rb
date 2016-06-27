class Api::V1::BaseController < ActionController::Base
  attr_accessor :current_app

  protect_from_forgery with: :exception
  before_action :requires_authentication_token
  skip_before_action :verify_authenticity_token,
                     if: -> (c) { c.request.format == 'application/json' }

  def requires_authentication_token
    authenticate_or_request_with_http_token do |token|
      @current_app ||= App.find_by(access_token: token)
      if current_app
        true
      else
        false
      end
    end
  end
end

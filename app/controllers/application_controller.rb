class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  private

  def render_success(data = {})
    render json: data, status: 200
  end

  def render_failure(msg)
    render json: { message: msg }, status: 400
  end
end

class ApplicationController < ActionController::Base
  # Note: :modern requires Safari 17.2+ which excludes iOS 16 and earlier
  allow_browser versions: { ie: false }

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :admin_signed_in?

  after_action :set_no_transform_cache_control

  private

  def set_no_transform_cache_control
    return unless response.media_type == "text/html"

    cache_control = response.headers["Cache-Control"]
    if cache_control.present?
      directives = cache_control.split(",").map(&:strip)
      return if directives.include?("no-transform")

      response.headers["Cache-Control"] = (directives + [ "no-transform" ]).join(", ")
    else
      response.headers["Cache-Control"] = "no-transform"
    end
  end

  SESSION_TIMEOUT = 12.hours

  def admin_signed_in?
    return false unless session[:admin_id]

    # 세션 타임아웃 확인
    if session[:admin_logged_in_at] &&
       Time.current.to_i - session[:admin_logged_in_at] > SESSION_TIMEOUT.to_i
      reset_session
      return false
    end

    Admin.exists?(id: session[:admin_id])
  end

  def authenticate_admin!
    unless admin_signed_in?
      redirect_to login_path, alert: "You must be logged in to access this section."
    end
  end
end

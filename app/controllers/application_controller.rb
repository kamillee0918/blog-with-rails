class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :admin_signed_in?

  private

  def admin_signed_in?
    session[:admin_id] == "admin"
  end

  def authenticate_admin!
    unless admin_signed_in?
      redirect_to login_path, alert: "You must be logged in to access this section."
    end
  end
end

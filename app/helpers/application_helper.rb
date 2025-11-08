module ApplicationHelper
  def user_signed_in?
    Current.session.present?
  end

  def current_user
    Current.user
  end

  # Alias for user_signed_in?
  alias_method :current_user?, :user_signed_in?
end

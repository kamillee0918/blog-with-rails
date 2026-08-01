class ApplicationController < ActionController::Base
  # Note: :modern requires Safari 17.2+ which excludes iOS 16 and earlier
  allow_browser versions: { ie: false }

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :admin_signed_in?

  after_action :set_no_transform_cache_control

  # ActionDispatch::Http::Cache::Response::DEFAULT_CACHE_CONTROL 과 같은 값이다.
  # Rails 는 커밋 직전 handle_conditional_get! 에서 Cache-Control 이 아직 비어 있을 때만
  # 이 기본값을 채운다. after_action 은 그보다 먼저 돌기 때문에 여기서 헤더에 손을 대면
  # (raw 헤더든 cache_control[:extras] 든) 기본값이 영영 적용되지 않는다.
  # 그러면 공개 HTML 이 max-age·must-revalidate 없이 나가고, 캐시는 RFC 9111 의
  # 휴리스틱 신선도로 떨어져 오래된 글일수록 오래 재검증 없이 캐시된다.
  # 그래서 기본 지시자를 직접 포함시킨다.
  CONDITIONAL_GET_CACHE_CONTROL = "max-age=0, private, must-revalidate"

  private

  def set_no_transform_cache_control
    return unless response.media_type == "text/html"

    directives = response.headers["Cache-Control"].to_s.split(",").map(&:strip).reject(&:blank?)
    directives = CONDITIONAL_GET_CACHE_CONTROL.split(",").map(&:strip) if directives.empty?
    return if directives.include?("no-transform")

    response.headers["Cache-Control"] = (directives + [ "no-transform" ]).join(", ")
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

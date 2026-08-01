# frozen_string_literal: true

class SessionsController < ApplicationController
  MAX_LOGIN_ATTEMPTS = 5
  LOCKOUT_DURATION = 15.minutes

  # Brute Force 보호.
  # 이전에는 시도 횟수를 세션에 저장했는데, 세션은 쿠키에 담기므로 공격자가
  # 쿠키를 버리고 요청하면 매번 카운터가 0 인 새 세션이 되어 제한이 없는 것과
  # 같았다. 서버 측 캐시(프로덕션은 Solid Cache)에 IP 별로 세면 클라이언트가
  # 무엇을 보내든 우회할 수 없다. 이메일이 맞을 때만 bcrypt(cost 12)가 도는데
  # 그 경우는 실패로 잡히므로 CPU 고갈 경로도 함께 막힌다.
  #
  # Rails 8 의 rate_limit 을 쓰지 않는다. 그것은 성공·실패를 가리지 않고 액션의
  # 모든 요청을 세고 성공 시 초기화할 방법을 주지 않아서, 계정이 하나뿐인 이
  # 블로그에서는 소유자가 정상 로그인을 몇 번 하는 것만으로 자기 사이트에서
  # 15분간 잠긴다. 여기서는 실패만 세고 성공하면 지운다.
  #
  # remote_ip 는 config/initializers/cloudflare.rb 가 Cloudflare 대역을
  # trusted_proxies 로 등록해 둔 덕분에 실제 클라이언트 IP 로 해석된다.
  before_action :reject_when_throttled, only: :create

  def new
    if admin_signed_in?
      redirect_to root_path, notice: "Already logged in."
    end
  end

  def create
    admin = Admin.find_by(email: params[:email])

    if admin&.authenticate(params[:password].to_s)
      clear_failed_attempts
      reset_session  # 세션 고정 공격 방지
      session[:admin_id] = admin.id
      session[:admin_logged_in_at] = Time.current.to_i
      redirect_to root_path, notice: "Logged in successfully."
    else
      attempts_left = [ MAX_LOGIN_ATTEMPTS - record_failed_attempt, 0 ].max
      flash.now[:alert] = "Invalid email or password. #{attempts_left} attempt(s) remaining."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Logged out."
  end

  private

  def reject_when_throttled
    return if failed_attempts < MAX_LOGIN_ATTEMPTS

    flash.now[:alert] = "Too many failed attempts. Try again in #{(LOCKOUT_DURATION / 60).to_i} minutes."
    render :new, status: :too_many_requests
  end

  def throttle_key
    "login/failed-attempts/#{request.remote_ip}"
  end

  def failed_attempts
    Rails.cache.read(throttle_key).to_i
  end

  # 새로 누적된 실패 횟수를 돌려준다. 키가 없으면 increment 가 amount 로 시작한다.
  # 창(window)은 첫 실패 시점부터 고정이라 실패를 반복해도 무한히 늘어나지 않는다.
  def record_failed_attempt
    Rails.cache.increment(throttle_key, 1, expires_in: LOCKOUT_DURATION).to_i
  end

  def clear_failed_attempts
    Rails.cache.delete(throttle_key)
  end
end

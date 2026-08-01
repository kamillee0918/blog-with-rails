# frozen_string_literal: true

class SessionsController < ApplicationController
  MAX_LOGIN_ATTEMPTS = 5
  LOCKOUT_DURATION = 15.minutes

  # Brute Force 보호.
  # 이전에는 시도 횟수를 세션에 저장했는데, 세션은 쿠키에 담기므로 공격자가
  # 쿠키를 버리고 요청하면 매번 카운터가 0 인 새 세션이 되어 제한이 없는 것과
  # 같았다. rate_limit 은 캐시(프로덕션은 Solid Cache)에 IP 별로 세므로
  # 클라이언트가 무엇을 보내든 우회할 수 없다.
  # 인증 없이 bcrypt(cost 12)를 무제한 호출시키는 CPU 고갈 경로도 함께 막힌다.
  rate_limit to: MAX_LOGIN_ATTEMPTS, within: LOCKOUT_DURATION, only: :create,
             with: -> { rate_limit_exceeded }

  def new
    if admin_signed_in?
      redirect_to root_path, notice: "Already logged in."
    end
  end

  def create
    admin = Admin.find_by(email: params[:email])

    if admin&.authenticate(params[:password].to_s)
      # 로그인 성공: 시도 횟수 초기화
      reset_login_attempts
      reset_session  # 세션 고정 공격 방지
      session[:admin_id] = admin.id
      session[:admin_logged_in_at] = Time.current.to_i
      redirect_to root_path, notice: "Logged in successfully."
    else
      # 로그인 실패: 시도 횟수 증가
      increment_login_attempts
      attempts_left = [ MAX_LOGIN_ATTEMPTS - login_attempt_count, 0 ].max
      flash.now[:alert] = "Invalid email or password. #{attempts_left} attempt(s) remaining."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to root_path, notice: "Logged out."
  end

  private

  def rate_limit_exceeded
    flash.now[:alert] = "Too many failed attempts. Try again in #{(LOCKOUT_DURATION / 60).to_i} minutes."
    render :new, status: :too_many_requests
  end

  # 남은 시도 횟수 안내는 오타를 낸 사용자를 위한 UX 일 뿐이다.
  # 세션에 있으므로 쿠키를 버리면 초기화되지만, 실제 차단은 rate_limit 이 맡는다.
  def login_attempt_count
    session[:login_attempts] || 0
  end

  def increment_login_attempts
    session[:login_attempts] = login_attempt_count + 1
  end

  def reset_login_attempts
    session.delete(:login_attempts)
  end
end

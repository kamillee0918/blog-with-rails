# frozen_string_literal: true

class SessionsController < ApplicationController
  # Brute Force 보호: 로그인 시도 횟수 제한
  MAX_LOGIN_ATTEMPTS = 5
  LOCKOUT_DURATION = 15.minutes

  def new
    if admin_signed_in?
      redirect_to root_path, notice: "Already logged in."
    end
  end

  def create
    # Lockout 상태 확인
    if locked_out?
      remaining = lockout_remaining_seconds
      flash.now[:alert] = "Too many failed attempts. Try again in #{(remaining / 60.0).ceil} minute(s)."
      render :new, status: :too_many_requests
      return
    end

    admin_password = resolve_admin_password

    if admin_password.nil?
      flash.now[:alert] = "Admin password is not configured. Please set ADMIN_PASSWORD environment variable."
      render :new, status: :service_unavailable
      return
    end

    if ActiveSupport::SecurityUtils.secure_compare(params[:password].to_s, admin_password)
      # 로그인 성공: 시도 횟수 초기화
      reset_login_attempts
      reset_session  # 세션 고정 공격 방지
      session[:admin_id] = "admin"
      redirect_to root_path, notice: "Logged in successfully."
    else
      # 로그인 실패: 시도 횟수 증가
      increment_login_attempts
      attempts_left = MAX_LOGIN_ATTEMPTS - login_attempt_count
      if attempts_left > 0
        flash.now[:alert] = "Invalid password. #{attempts_left} attempt(s) remaining."
      else
        flash.now[:alert] = "Too many failed attempts. Account locked for #{(LOCKOUT_DURATION / 60).to_i} minutes."
      end
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:admin_id] = nil
    redirect_to root_path, notice: "Logged out."
  end

  private

  # 프로덕션에서는 환경변수 필수, 개발/테스트에서는 fallback 허용
  def resolve_admin_password
    env_password = ENV["ADMIN_PASSWORD"]

    if Rails.env.production?
      # 프로덕션에서는 환경변수가 반드시 설정되어 있어야 함
      if env_password.blank?
        Rails.logger.error("[SECURITY] ADMIN_PASSWORD environment variable is not set in production!")
        return nil
      end
      env_password
    else
      # 개발/테스트 환경에서만 fallback 허용
      env_password || "password"
    end
  end

  # === Brute Force Protection (세션 기반) ===

  def login_attempt_count
    session[:login_attempts] || 0
  end

  def increment_login_attempts
    session[:login_attempts] = login_attempt_count + 1
    session[:last_failed_at] = Time.current.to_i if login_attempt_count >= MAX_LOGIN_ATTEMPTS
  end

  def reset_login_attempts
    session.delete(:login_attempts)
    session.delete(:last_failed_at)
  end

  def locked_out?
    return false if login_attempt_count < MAX_LOGIN_ATTEMPTS

    last_failed = session[:last_failed_at]
    return false unless last_failed

    Time.current.to_i - last_failed < LOCKOUT_DURATION.to_i
  end

  def lockout_remaining_seconds
    last_failed = session[:last_failed_at] || Time.current.to_i
    elapsed = Time.current.to_i - last_failed
    [ LOCKOUT_DURATION.to_i - elapsed, 0 ].max
  end
end

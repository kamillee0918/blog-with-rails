class SessionsController < ApplicationController
  before_action :authenticate, only: %i[ index ]
  before_action :set_session, only: :destroy, if: -> { params[:id].present? }

  def index
    @sessions = Current.user.sessions.order(created_at: :desc)
  end

  def new
  end

  def create
    email = params[:user]&.[](:email) || params[:email]
    # verified=true인 사용자만 로그인 가능 (Magic Link 인증 완료한 사용자)
    user = User.find_by(email: email&.downcase&.strip, verified: true)

    unless user
      render json: {
        success: false,
        errors: [ "Failed to find user with email" ]
      }, status: :not_found
      return
    end

    # Magic Link & OTP 생성 및 발송 (Service 사용)
    service = Authentication::MagicLinkService.new(user)
    if service.generate_and_send(include_otp: true)
      # OTP 입력 대기 상태로 세션 설정
      session[:pending_user_id] = user.id
      session[:pending_user_token] = user.magic_link_token

      render json: {
        success: true,
        message: "Magic Link를 이메일로 전송했습니다. 링크를 확인해주세요.",
        email: user.email
      }, status: :ok
    else
      render json: {
        success: false,
        errors: service.errors
      }, status: :unprocessable_entity
    end
  end

  def magic_link
    # Magic Link 검증 (Service 사용)
    user = Authentication::MagicLinkService.find_and_verify(params[:token])

    if user
      # verified 상태로 회원가입인지 로그인인지 구분
      is_signup = !user.verified?

      # 이메일 인증 완료
      user.update(verified: true) if is_signup

      # 세션 생성
      @session = user.sessions.create!
      set_session_cookie(@session)

      # Magic Link 토큰 무효화
      user.regenerate_magic_link_token

      # 세션 정리
      session.delete(:pending_user_id)
      session.delete(:pending_user_token)

      # 회원가입/로그인에 따라 다른 action 파라미터로 리다이렉트
      action_type = is_signup ? "signup" : "signin"
      redirect_to "#{root_path}?action=#{action_type}&success=true"
    else
      # Magic Link 만료 처리
      # 만료된 토큰으로 사용자 찾기 (verified 상태로 회원가입/로그인 구분)
      expired_user = User.find_by(magic_link_token: params[:token])

      if expired_user
        is_signup_attempt = !expired_user.verified?

        # 미인증 상태인 경우에만 삭제 (유령 계정 방지)
        if is_signup_attempt
          expired_user.destroy
          Rails.logger.info "Deleted unverified user (expired Magic Link): #{expired_user.email}"
        end

        # 회원가입/로그인 실패에 따라 다른 리다이렉트
        if Current.user
          redirect_path = "#{root_path}?action=account&expired=true"
        else
          action_type = is_signup_attempt ? "signup" : "signin"
          redirect_path = "#{root_path}?action=#{action_type}&success=false"
        end

        redirect_to redirect_path
      else
        # 토큰으로 사용자를 찾을 수 없는 경우 (이미 삭제됨 등)
        redirect_to "#{root_path}?action=signin&success=false"
      end
    end
  end

  # OTP 검증 페이지 (필요시)
  def otp_verification
    # 세션에 pending_user_id가 없으면 로그인 페이지로
    redirect_to signin_path, alert: "세션이 만료되었습니다." unless session[:pending_user_id]
  end

  def destroy
    # params[:id]가 없으면 현재 세션을 사용
    @session ||= Current.session

    if @session
      @session.destroy
      delete_session_cookie

      respond_to do |format|
        format.html { redirect_to root_path, notice: "로그아웃되었습니다." }
        format.json { render json: { success: true, message: "로그아웃되었습니다." }, status: :ok }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path, alert: "세션을 찾을 수 없습니다." }
        format.json { render json: { success: false, error: "세션을 찾을 수 없습니다." }, status: :not_found }
      end
    end
  end

  private
    def set_session
      @session = Current.user.sessions.find(params[:id]) if params[:id]
    end
end

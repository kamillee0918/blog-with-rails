# frozen_string_literal: true

module Members
  module Api
    class OtpController < ApplicationController
      # POST /members/api/verify-otp
      # OTP 검증 및 세션 생성
      def create
        user = User.find_by(id: session[:pending_user_id])
        otp_code = params[:otp_code]

        unless user
          render json: {
            message: "Session expired. Please request a new code.",
            type: "BadRequestError",
            code: "SESSION_EXPIRED",
            success: false
          }, status: :bad_request
          return
        end

        # OTP 검증 및 세션 생성 (Service 사용)
        service = Authentication::OtpService.new(user)
        @session = service.verify_and_create_session(otp_code)

        if @session
          set_session_cookie(@session)

          # Session 정리
          session.delete(:pending_user_id)
          session.delete(:pending_user_token)

          render json: {
            message: "OTP verification successful.",
            type: "Success",
            code: "OTP_VERIFIED",
            success: true,
            redirect_url: "/?action=signin&success=true",
            user: {
              id: user.id,
              nickname: user.nickname,
              email: user.email
            }
          }, status: :ok
        else
          render json: {
            message: service.errors.first || "Invalid verification code.",
            type: "BadRequestError",
            code: "INVALID_OTC",
            success: false
          }, status: :bad_request
        end
      end
    end
  end
end

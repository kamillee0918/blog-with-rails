# frozen_string_literal: true

module Members
  module Api
    class MagicLinkController < ApplicationController
      # POST /members/api/send-magic-link
      # Magic Link 및 OTP 전송
      def create
        nickname = params[:nickname]
        email = params[:email]
        email_type = params[:emailType] # 'signup' or 'signin'
        integrity_token = params[:integrityToken]
        auto_redirect = params[:autoRedirect]
        include_otc = params[:includeOTC]

        # IntegrityToken 검증
        unless verify_integrity_token(integrity_token)
          render json: {
            errors: [
              {
                message: "Invalid integrity token",
                type: "BadRequestError"
              }
            ]
          }, status: :bad_request
          return
        end

        # 이메일 유효성 검증
        unless valid_email?(email)
          render json: {
            errors: [
              {
                message: "Email is not valid",
                type: "BadRequestError"
              }
            ]
          }, status: :bad_request
          return
        end

        # emailType에 따라 회원가입 또는 로그인 처리
        if email_type == "signup"
          handle_signup(nickname, email)
        elsif email_type == "signin"
          handle_signin(email, include_otc)
        else
          render json: {
            errors: [
              {
                message: "Invalid email type",
                type: "BadRequestError"
              }
            ]
          }, status: :bad_request
        end
      end

      private

      # 회원가입 처리
      def handle_signup(nickname, email)
        # 이미 가입된 사용자인지 확인
        existing_user = User.find_by(email: email&.downcase&.strip)

        if existing_user
          render json: {
            errors: [
              {
                message: "This email address is already registered. Please sign in instead.",
                type: "BadRequestError"
              }
            ]
          }, status: :bad_request
          return
        end

        # 새 사용자 생성 (verified=false)
        user = User.new(
          nickname: nickname,
          email: email&.downcase&.strip,
          verified: false
        )

        if user.save
          # Magic Link만 발송 (OTP 없이)
          service = Authentication::MagicLinkService.new(user)
          if service.generate_and_send(include_otp: false)
            # IntegrityToken 무효화
            session.delete(:integrity_token)
            session.delete(:integrity_token_created_at)

            render json: {
              message: "Magic Link sent to your email"
            }, status: :created
          else
            # Magic Link 발송 실패 시 생성된 사용자 삭제
            user.destroy
            render json: {
              errors: [
                {
                  type: "InternalServerError",
                  message: service.errors.first || "Failed to send magic link"
                }
              ]
            }, status: :internal_server_error
          end
        else
          render json: {
            errors: [
              {
                message: user.errors.full_messages.first,
                type: "BadRequestError"
              }
            ]
          }, status: :bad_request
        end
      end

      # 로그인 처리
      def handle_signin(email, include_otc)
        # 사용자 찾기 (verified=true인 사용자만 로그인 가능)
        user = User.find_by(email: email&.downcase&.strip, verified: true)

        unless user
          render json: {
            errors: [
              {
                message: "No member exists with this e-mail address. Please sign up first.",
                type: "BadRequestError",
                id: nil
              }
            ]
          }, status: :bad_request
          return
        end

        # Magic Link & OTP 생성 및 발송 (Service 사용)
        service = Authentication::MagicLinkService.new(user)
        if service.generate_and_send(include_otp: include_otc)
          # OTP 입력 대기 상태로 세션 설정
          session[:pending_user_id] = user.id
          session[:pending_user_token] = user.magic_link_token

          # IntegrityToken 무효화
          session.delete(:integrity_token)
          session.delete(:integrity_token_created_at)

          render json: {
            message: "OTP Code Generated"
          }, status: :created
        else
          render json: {
            errors: [
              {
                type: "InternalServerError",
                message: service.errors.first || "Failed to generate magic link"
              }
            ]
          }, status: :internal_server_error
        end
      end

      def verify_integrity_token(token)
        stored_token = session[:integrity_token]
        created_at = session[:integrity_token_created_at]

        return false unless stored_token.present?
        return false unless created_at.present?
        return false unless token == stored_token

        # IntegrityToken은 5분간 유효
        Time.current.to_i - created_at < 300
      end

      # 이메일 유효성 검증(정규식과 동일한 패턴 사용)
      def valid_email?(email)
        return false if email.blank?

        email_regex = /\A[a-zA-Z0-9]([a-zA-Z0-9._-]*[a-zA-Z0-9])?@[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?\.([a-zA-Z]{2,6})\z/
        email.match?(email_regex)
      end
    end
  end
end

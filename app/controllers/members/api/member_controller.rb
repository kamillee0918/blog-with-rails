# frozen_string_literal: true

module Members
  module Api
    class MemberController < ApplicationController
      before_action :authenticate_user!

      # GET /members/api/member
      # 현재 로그인한 사용자 정보 반환
      def show
        render json: {
          id: Current.user.id,
          email: Current.user.email,
          name: Current.user.nickname,
          verified: Current.user.verified,
          enable_newsletter_notifications: Current.user.enable_newsletter_notifications,
          unsubscribe: Current.user.deleted_at.present?
        }
      end

      # PUT /members/api/member
      # 사용자 정보 업데이트 (닉네임, 이메일, 뉴스레터 구독 설정)
      def update
        user = Current.user
        user_params = params[:user] || {}

        # 업데이트할 속성 추출
        update_attrs = {}
        update_attrs[:enable_newsletter_notifications] = user_params[:enable_newsletter_notifications] if user_params.key?(:enable_newsletter_notifications)
        update_attrs[:nickname] = user_params[:nickname] if user_params[:nickname].present?
        update_attrs[:email] = user_params[:email] if user_params[:email].present?

        if update_attrs.empty?
          render json: {
            errors: [ "No valid parameters provided" ]
          }, status: :unprocessable_entity
          return
        end

        # 이메일 변경 시 verified를 false로 설정
        update_attrs[:verified] = false if update_attrs[:email].present?

        if user.update(update_attrs)
          render json: {
            id: user.id,
            email: user.email,
            name: user.nickname,
            verified: user.verified,
            enable_newsletter_notifications: user.enable_newsletter_notifications
          }
        else
          render json: {
            errors: user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      # DELETE /members/api/member
      # 회원 탈퇴 (Soft Delete)
      def destroy
        user = Current.user

        begin
          user.soft_delete!
          # 모든 세션 삭제
          user.sessions.destroy_all

          render json: {
            success: true,
            message: "Your account has been successfully deleted"
          }
        rescue StandardError => e
          render json: {
            errors: [ e.message ]
          }, status: :unprocessable_entity
        end
      end

      # POST /members/api/member/email
      # 이메일 변경 요청 (이메일 인증 필요)
      def update_email
        user = Current.user
        new_email = params[:email]
        identity_token = params[:identity]

        # 이메일 유효성 검사
        unless new_email.present? && new_email.match?(URI::MailTo::EMAIL_REGEXP)
          render json: {
            errors: [ "Invalid email format" ]
          }, status: :unprocessable_entity
          return
        end

        # Identity 토큰 검증
        unless identity_token.present?
          render json: {
            errors: [ "Identity token is required" ]
          }, status: :unprocessable_entity
          return
        end

        # 이메일 중복 확인
        if User.where.not(id: user.id).exists?(email: new_email)
          render json: {
            errors: [ "Email is already taken" ]
          }, status: :unprocessable_entity
          return
        end

        # 이메일 변경 요청 처리
        # Identity::EmailsController의 update 액션을 사용하는 대신
        # 직접 이메일 변경 처리
        begin
          user.update!(email: new_email, verified: false)

          # 이메일 인증 토큰 생성 및 이메일 발송
          send_email_verification(user)

          render json: {
            success: true,
            message: "Please check your email to verify the change"
          }
        rescue ActiveRecord::RecordInvalid => e
          render json: {
            errors: [ e.message ]
          }, status: :unprocessable_entity
        end
      end

      private

      def authenticate_user!
        unless Current.user
          render json: {
            errors: [ "Authentication required" ]
          }, status: :unauthorized
        end
      end

      def send_email_verification(user)
        # TODO: 실제 이메일 발송 로직 구현
        # 개발 환경에서는 콘솔에 출력
        if Rails.env.development?
          token = generate_verification_token(user)
          verification_url = identity_email_verification_url(sid: token, host: request.host_with_port)

          Rails.logger.info "=" * 81
          Rails.logger.info "Email Verification Link:"
          Rails.logger.info verification_url
          Rails.logger.info "=" * 81
        end
      end

      def generate_verification_token(user)
        # TODO: 실제 토큰 생성 로직 구현
        # 임시로 간단한 토큰 생성
        user.signed_id(purpose: :verify_email, expires_in: 2.days)
      end
    end
  end
end

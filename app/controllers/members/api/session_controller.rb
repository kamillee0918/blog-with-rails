# frozen_string_literal: true

module Members
  module Api
    class SessionController < ApplicationController
      # GET /members/api/session
      # 현재 세션 정보 반환 (인증 여부 및 identity 토큰)
      def show
        if Current.user
          # Identity 토큰 생성
          identity_token = generate_identity_token(Current.user)

          render json: {
            authenticated: true,
            user: {
              id: Current.user.id,
              email: Current.user.email,
              name: Current.user.nickname,
              verified: Current.user.verified
            },
            identity: identity_token
          }
        else
          render json: {
            authenticated: false,
            identity: nil
          }
        end
      end

      # DELETE /members/api/session
      # 현재 세션 삭제 (로그아웃)
      def destroy
        if Current.session
          # 세션 삭제
          Current.session.destroy

          # 쿠키 삭제 (통일된 메서드 사용)
          delete_session_cookie

          render json: {
            success: true,
            message: "Successfully logged out"
          }, status: :ok
        else
          render json: {
            success: false,
            error: "No active session"
          }, status: :unauthorized
        end
      end

      private

      def generate_identity_token(user)
        # Identity 토큰 생성 (2시간 유효)
        # 이메일 변경 시 사용자 확인용
        user.signed_id(purpose: :identity, expires_in: 2.hours)
      end
    end
  end
end

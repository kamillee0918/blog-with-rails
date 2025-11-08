# frozen_string_literal: true

# Authenticatable concern
# 인증 관련 공통 기능을 제공하는 모듈
module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :set_current_request_details
    before_action :set_current_session
  end

  private
    # 세션을 Current에 설정 (선택적)
    def set_current_session
      if session_record = Session.find_by_id(cookies.signed[:session_token])
        Current.session = session_record
      end
    end

    # 통합된 세션 쿠키 설정 메서드
    # @param session_record [Session] 설정할 세션 레코드
    # @param expires_in [ActiveSupport::Duration] 쿠키 만료 시간 (기본: 30일)
    def set_session_cookie(session_record, expires_in: 30.days)
      cookies.signed[:session_token] = {
        value: session_record.id,
        expires: expires_in.from_now,
        httponly: true,
        secure: Rails.env.production?,
        same_site: :lax
      }
    end

    # 세션 쿠키 삭제
    def delete_session_cookie
      cookies.delete(:session_token)
    end

    # 인증 필수 (로그인 필요한 페이지에서 사용)
    def authenticate
      redirect_to signin_path unless Current.user
    end

    # 인증 실패
    # def unauthorized
    #   head :no_content
    # end

    def set_current_request_details
      Current.user_agent = request.user_agent
      Current.ip_address = request.ip
    end
end

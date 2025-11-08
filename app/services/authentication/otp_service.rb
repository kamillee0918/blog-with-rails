# frozen_string_literal: true

module Authentication
  # OTP (One-Time Password) 검증 서비스
  class OtpService
    attr_reader :user, :errors

    # OTP 최대 시도 횟수
    MAX_ATTEMPTS = 5

    def initialize(user)
      @user = user
      @errors = []
    end

    # OTP 검증 및 세션 생성
    # @param otp_code [String] 입력된 OTP 코드
    # @return [Session, nil] 생성된 세션 또는 nil
    def verify_and_create_session(otp_code)
      unless user
        @errors << "User not found"
        return nil
      end

      unless valid_otp?(otp_code)
        log_failed_attempt
        return nil
      end

      # OTP 검증 성공 - 즉시 무효화 (재사용 방지)
      invalidate_otp!

      # 사용자 상태 업데이트
      user.update(verified: true)

      # 세션 생성
      user.sessions.create!
    rescue StandardError => e
      @errors << e.message
      Rails.logger.error "OTP verification failed: #{e.message}"
      nil
    end

    # OTP 유효성 검증 (사용 후 무효화하지 않음)
    # @param otp_code [String] 입력된 OTP 코드
    # @return [Boolean] 유효 여부
    def valid_otp?(otp_code)
      return false unless user.email_otp_code.present?
      return false unless user.email_otp_expires_at.present?

      # OTP 만료 확인
      if user.email_otp_expires_at < Time.current
        @errors << "OTP code has expired"
        return false
      end

      # 공백 제거 후 비교
      if user.email_otp_code.strip == otp_code.to_s.strip
        true
      else
        @errors << "Invalid OTP code"
        false
      end
    end

    # OTP 즉시 무효화 (재사용 방지)
    def invalidate_otp!
      user.update!(
        email_otp_code: nil,
        email_otp_expires_at: nil
      )
    end

    private

    def log_failed_attempt
      Rails.logger.warn "[OTP] Failed verification attempt for user #{user.id}"
    end
  end
end

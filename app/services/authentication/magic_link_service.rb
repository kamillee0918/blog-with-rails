# frozen_string_literal: true

module Authentication
  # Magic Link 생성 및 발송 서비스
  class MagicLinkService
    attr_reader :user, :errors

    def initialize(user)
      @user = user
      @errors = []
    end

    # Magic Link 생성 및 OTP 발송
    # @param include_otp [Boolean] OTP 코드 포함 여부
    # @return [Boolean] 성공 여부
    def generate_and_send(include_otp: true)
      return false unless user

      # Magic Link 토큰 생성
      user.regenerate_magic_link_token
      user.update(magic_link_sent_at: Time.current)

      # OTP 생성 (선택적)
      otp_code = nil
      if include_otp
        otp_code = user.generate_email_otp
        user.update(
          email_otp_code: otp_code,
          email_otp_expires_at: 5.minutes.from_now
        )
      end

      # 이메일 발송
      send_email(otp_code)

      true
    rescue StandardError => e
      @errors << e.message
      Rails.logger.error "Magic Link generation failed: #{e.message}"
      false
    end

    # Magic Link 유효성 검증
    # @param token [String] Magic Link 토큰
    # @return [Boolean] 유효 여부
    def self.valid?(user)
      return false if user.nil?
      return false if user.magic_link_sent_at.nil?

      # Magic Link 유효 기간:
      # - Production: 15분
      # - Test: 1분 (테스트 안정성)
      # - Development: 30초 (빠른 테스트용)
      expiry_time = if Rails.env.production?
                      15.minutes.ago
      elsif Rails.env.test?
                      1.minutes.ago
      else
                      30.seconds.ago
      end
      user.magic_link_sent_at > expiry_time
    end

    # Magic Link 토큰으로 사용자 찾기 및 검증
    # @param token [String] Magic Link 토큰
    # @return [User, nil] 유효한 사용자 또는 nil
    def self.find_and_verify(token)
      user = User.find_by(magic_link_token: token)
      return nil unless user && valid?(user)

      user
    end

    private

    def send_email(otp_code)
      if Rails.env.development?
        log_magic_link(otp_code)
      else
        # 프로덕션: 실제 이메일 전송
        UserMailer.magic_link_with_otp(user, otp_code).deliver_later
      end
    end

    def log_magic_link(otp_code)
      magic_link_url = Rails.application.routes.url_helpers.magic_link_url(
        token: user.magic_link_token,
        host: "localhost:3000"
      )

      puts "\n" + "=" * 81
      puts "🔐 Magic Link & OTP Code"
      puts "=" * 81
      puts "Email: #{user.email}"
      puts "Magic Link: #{magic_link_url}"
      puts "Magic Link Expires at: #{user.magic_link_sent_at}"
      puts "OTP Code: #{otp_code}" if otp_code
      puts "OTP Expires at: #{user.email_otp_expires_at}" if otp_code
      puts "=" * 81 + "\n"
    end
  end
end

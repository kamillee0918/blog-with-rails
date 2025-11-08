class User < ApplicationRecord
  generates_token_for :email_verification, expires_in: 2.days do
    email
  end

  has_secure_token :magic_link_token, length: 36

  has_many :sessions, dependent: :destroy
  has_many :posts, dependent: :nullify

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :nickname, presence: true

  normalizes :email, with: -> { _1.strip.downcase }

  # Soft delete scope
  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }
  scope :newsletter_subscribers, -> { active.where(enable_newsletter_notifications: true, verified: true) }

  before_validation if: :email_changed?, on: :update do
    self.verified = false
  end

  # Soft delete
  def soft_delete!
    update!(deleted_at: Time.current)
  end

  def soft_delete
    update(deleted_at: Time.current)
  end

  def deleted?
    deleted_at.present?
  end

  def restore!
    update!(deleted_at: nil)
  end

  def restore
    update(deleted_at: nil)
  end

  # 6자리 OTP 생성
  # @return [String] 6자리 숫자 OTP
  def generate_email_otp
    # SecureRandom을 사용하여 암호학적으로 안전한 난수 생성
    SecureRandom.random_number(1000000).to_s.rjust(6, "0")
  end

  # OTP 검증
  # 이 메서드는 하위 호환성을 위해 유지되며, OTP를 무효화하지 않습니다
  # @param code [String] 입력된 OTP 코드
  # @return [Boolean] 검증 성공 여부
  def verify_email_otp(code)
    return false unless email_otp_code.present?
    return false unless email_otp_expires_at.present?
    return false if email_otp_expires_at < Time.current

    # 공백 제거 후 비교
    email_otp_code.strip == code.to_s.strip
  end

  # OTP 검증 및 즉시 무효화 (재사용 방지)
  # @param code [String] 입력된 OTP 코드
  # @return [Boolean] 검증 성공 여부
  def verify_and_consume_otp!(code)
    return false unless verify_email_otp(code)

    # 검증 성공 시 즉시 무효화
    update!(email_otp_code: nil, email_otp_expires_at: nil)
    true
  rescue StandardError => e
    Rails.logger.error "OTP consumption failed: #{e.message}"
    false
  end
end

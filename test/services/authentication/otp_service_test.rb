require "test_helper"

module Authentication
  class OtpServiceTest < ActiveSupport::TestCase
    def setup
      @user = User.create!(
        email: "test@example.com",
        nickname: "Test User",
        verified: true,
        email_otp_code: "123456",
        email_otp_expires_at: 5.minutes.from_now
      )
    end

    test "verify_and_create_session creates session with valid OTP" do
      service = OtpService.new(@user)

      session = service.verify_and_create_session("123456")

      assert_not_nil session
      assert_instance_of Session, session
      assert_equal @user.id, session.user_id
    end

    test "verify_and_create_session invalidates OTP after successful verification" do
      service = OtpService.new(@user)

      session = service.verify_and_create_session("123456")

      assert_not_nil session
      @user.reload
      assert_nil @user.email_otp_code
      assert_nil @user.email_otp_expires_at
    end

    test "verify_and_create_session returns nil with invalid OTP" do
      service = OtpService.new(@user)

      session = service.verify_and_create_session("999999")

      assert_nil session
      assert_includes service.errors, "Invalid OTP code"
    end

    test "verify_and_create_session returns nil with expired OTP" do
      @user.update!(email_otp_expires_at: 1.minute.ago)
      service = OtpService.new(@user)

      session = service.verify_and_create_session("123456")

      assert_nil session
      assert_includes service.errors, "OTP code has expired"
    end

    test "verify_and_create_session returns nil when user is nil" do
      service = OtpService.new(nil)

      session = service.verify_and_create_session("123456")

      assert_nil session
      assert_includes service.errors, "User not found"
    end

    test "valid_otp? returns true for valid OTP" do
      service = OtpService.new(@user)

      assert service.valid_otp?("123456")
    end

    test "valid_otp? returns false for invalid OTP" do
      service = OtpService.new(@user)

      assert_not service.valid_otp?("999999")
    end

    test "valid_otp? handles whitespace in OTP code" do
      service = OtpService.new(@user)

      assert service.valid_otp?(" 123456 ")
    end

    test "invalidate_otp! clears OTP fields" do
      service = OtpService.new(@user)

      service.invalidate_otp!
      @user.reload

      assert_nil @user.email_otp_code
      assert_nil @user.email_otp_expires_at
    end

    test "verify_and_create_session updates user verified status" do
      @user.update!(verified: false)
      service = OtpService.new(@user)

      session = service.verify_and_create_session("123456")

      assert_not_nil session
      @user.reload
      assert @user.verified
    end
  end
end

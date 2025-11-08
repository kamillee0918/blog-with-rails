require "test_helper"

module Authentication
  class MagicLinkServiceTest < ActiveSupport::TestCase
    def setup
      @user = User.create!(
        email: "test@example.com",
        nickname: "Test User",
        verified: true
      )
    end

    test "generate_and_send creates magic link token" do
      service = MagicLinkService.new(@user)

      assert service.generate_and_send(include_otp: false)

      @user.reload
      assert_not_nil @user.magic_link_token
      assert_not_nil @user.magic_link_sent_at
    end

    test "generate_and_send creates OTP when requested" do
      service = MagicLinkService.new(@user)

      assert service.generate_and_send(include_otp: true)

      @user.reload
      assert_not_nil @user.email_otp_code
      assert_not_nil @user.email_otp_expires_at
      assert_equal 6, @user.email_otp_code.length
    end

    test "valid? returns true for recent magic link" do
      @user.update!(magic_link_sent_at: 30.seconds.ago)

      assert MagicLinkService.valid?(@user)
    end

    test "valid? returns false for expired magic link in test" do
      @user.update!(magic_link_sent_at: 2.minutes.ago)

      assert_not MagicLinkService.valid?(@user)
    end

    test "valid? returns false when magic_link_sent_at is nil" do
      @user.update!(magic_link_sent_at: nil)

      assert_not MagicLinkService.valid?(@user)
    end

    test "find_and_verify returns user when token is valid" do
      @user.update!(
        magic_link_token: "valid_token",
        magic_link_sent_at: 30.seconds.ago
      )

      found_user = MagicLinkService.find_and_verify("valid_token")

      assert_equal @user, found_user
    end

    test "find_and_verify returns nil when token is invalid" do
      found_user = MagicLinkService.find_and_verify("invalid_token")

      assert_nil found_user
    end

    test "find_and_verify returns nil when token is expired" do
      @user.update!(
        magic_link_token: "expired_token",
        magic_link_sent_at: 2.minutes.ago
      )

      found_user = MagicLinkService.find_and_verify("expired_token")

      assert_nil found_user
    end
  end
end

require "test_helper"

class Identity::EmailVerificationsControllerTest < ActionDispatch::IntegrationTest
  # Note: Email verification is handled through Magic Link system
  # These tests are skipped but kept for reference

  setup do
    skip "Email verification handled by Magic Link system"
  end

  test "should send a verification email" do
    # Skipped - Magic Link handles verification
  end

  test "should verify email" do
    # Skipped - Magic Link handles verification
  end

  test "should not verify email with expired token" do
    # Skipped - Magic Link handles verification
  end
end

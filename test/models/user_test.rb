require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "test@example.com",
      nickname: "Test User"
    )
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require email" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "should require nickname" do
    @user.nickname = nil
    assert_not @user.valid?
    assert_includes @user.errors[:nickname], "can't be blank"
  end

  test "should require unique email" do
    @user.save!
    duplicate_user = User.new(email: @user.email, nickname: "Another User")

    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "should normalize email to lowercase" do
    @user.email = "TEST@EXAMPLE.COM"
    @user.save!

    assert_equal "test@example.com", @user.email
  end

  test "should validate email format" do
    invalid_emails = %w[user.example.com @example.com user@ user]

    invalid_emails.each do |invalid_email|
      @user.email = invalid_email
      assert_not @user.valid?, "#{invalid_email} should be invalid"
    end
  end

  test "generate_email_otp should return 6-digit string" do
    otp = @user.generate_email_otp

    assert_equal 6, otp.length
    assert_match(/\A\d{6}\z/, otp)
  end

  test "verify_email_otp should return true with valid OTP" do
    @user.email_otp_code = "123456"
    @user.email_otp_expires_at = 5.minutes.from_now

    assert @user.verify_email_otp("123456")
  end

  test "verify_email_otp should return false with invalid OTP" do
    @user.email_otp_code = "123456"
    @user.email_otp_expires_at = 5.minutes.from_now

    assert_not @user.verify_email_otp("999999")
  end

  test "verify_email_otp should return false with expired OTP" do
    @user.email_otp_code = "123456"
    @user.email_otp_expires_at = 1.minute.ago

    assert_not @user.verify_email_otp("123456")
  end

  test "verify_email_otp should handle whitespace" do
    @user.email_otp_code = "123456"
    @user.email_otp_expires_at = 5.minutes.from_now

    assert @user.verify_email_otp(" 123456 ")
  end

  test "verify_and_consume_otp! should invalidate OTP after verification" do
    @user.save!
    @user.update!(
      email_otp_code: "123456",
      email_otp_expires_at: 5.minutes.from_now
    )

    assert @user.verify_and_consume_otp!("123456")

    @user.reload
    assert_nil @user.email_otp_code
    assert_nil @user.email_otp_expires_at
  end

  test "verify_and_consume_otp! should return false with invalid OTP" do
    @user.save!
    @user.update!(
      email_otp_code: "123456",
      email_otp_expires_at: 5.minutes.from_now
    )

    assert_not @user.verify_and_consume_otp!("999999")

    @user.reload
    # OTP should not be invalidated on failure
    assert_equal "123456", @user.email_otp_code
  end

  test "should set verified to false when email changes" do
    @user.verified = true
    @user.save!

    @user.email = "newemail@example.com"
    @user.save!

    assert_not @user.verified
  end

  test "should have magic_link_token after creation" do
    @user.save!

    assert_not_nil @user.magic_link_token
  end

  test "should be able to regenerate magic_link_token" do
    @user.save!
    old_token = @user.magic_link_token

    @user.regenerate_magic_link_token

    assert_not_equal old_token, @user.magic_link_token
  end

  test "should have many sessions" do
    assert_respond_to @user, :sessions
  end

  test "should destroy associated sessions when user is destroyed" do
    @user.save!
    session = @user.sessions.create!

    assert_difference "Session.count", -1 do
      @user.destroy
    end
  end
end

require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:lazaro_nixon)
    @otp_code = "123456"
  end

  test "magic_link_with_otp" do
    mail = UserMailer.magic_link_with_otp(@user, @otp_code)

    assert_equal "로그인 인증 코드", mail.subject
    assert_equal [ @user.email ], mail.to
    assert_match @otp_code, mail.body.encoded
  end
end

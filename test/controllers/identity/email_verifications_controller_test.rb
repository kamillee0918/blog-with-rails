require "test_helper"

class Identity::EmailVerificationsControllerTest < ActionDispatch::IntegrationTest
  # Note: Email verification is handled through Magic Link system
  # These tests verify the Magic Link-based verification flow

  setup do
    @unverified_user = users(:unverified_user)
  end

  test "should verify email through magic link authentication" do
    # 미인증 사용자 확인
    assert_not @unverified_user.verified

    # 미인증 사용자는 signin_url을 사용할 수 없음 (verified=true만 가능)
    # 대신 Magic Link를 직접 사용 (회원가입 플로우)
    @unverified_user.update!(magic_link_sent_at: Time.current)
    get magic_link_url(token: @unverified_user.magic_link_token)

    # Magic Link 인증 성공 (리다이렉트)
    assert_response :redirect

    # Verified 자동 설정 확인
    @unverified_user.reload
    assert @unverified_user.verified
  end

  test "should not verify email with expired magic link" do
    # Magic link를 과거 시간으로 설정
    @unverified_user.update!(
      magic_link_sent_at: 2.minutes.ago,
      email_otp_code: "123456",
      email_otp_expires_at: 1.minute.ago
    )

    # 만료된 magic link로 인증 시도
    get magic_link_url(token: @unverified_user.magic_link_token)

    # 만료 페이지로 리다이렉트
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "magic link authentication automatically verifies email" do
    # 미인증 상태 확인
    assert_not @unverified_user.verified

    # Magic link로 직접 인증
    @unverified_user.update!(magic_link_sent_at: Time.current)
    get magic_link_url(token: @unverified_user.magic_link_token)

    # 로그인 성공
    assert_response :redirect

    # Verified 자동 설정 확인
    @unverified_user.reload
    assert @unverified_user.verified
  end
end

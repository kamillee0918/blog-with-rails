require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:lazaro_nixon)
  end

  test "should get index" do
    # Magic Link 인증으로 로그인
    sign_in_as @user

    get sessions_url
    assert_response :success
  end

  test "should get new" do
    get signin_url
    assert_response :success
  end

  test "should request magic link with JSON" do
    post signin_url, params: { email: @user.email }, as: :json

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert json_response["success"]
    assert_equal @user.email, json_response["email"]
  end

  test "should not request magic link for unverified user" do
    unverified = users(:unverified_user)

    post signin_url, params: { email: unverified.email }, as: :json

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_not json_response["success"]
  end

  test "should verify OTP and create session" do
    # 1. Magic link 요청 (OTP 포함)
    post signin_url, params: { email: @user.email }, as: :json
    assert_response :ok

    # 2. OTP가 생성되었는지 확인
    @user.reload
    assert_not_nil @user.email_otp_code
    assert_not_nil @user.email_otp_expires_at

    # 3. OTP로 로그인
    post members_api_verify_otp_url, params: { otp_code: @user.email_otp_code }, as: :json
    assert_response :ok

    # 4. 세션이 생성되었는지 확인
    json_response = JSON.parse(response.body)
    assert json_response["success"]
  end

  test "should sign out with JSON" do
    # Magic Link 인증으로 로그인
    sign_in_as @user

    # 로그아웃
    delete signin_url, as: :json
    assert_response :ok

    # 로그아웃 후 인증 확인
    json_response = JSON.parse(response.body)
    assert json_response["success"]
  end
end

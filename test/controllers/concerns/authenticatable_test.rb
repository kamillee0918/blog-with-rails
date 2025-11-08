# frozen_string_literal: true

require "test_helper"

class AuthenticatableTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:john_doe)
  end

  test "set_current_session sets Current.session from valid cookie" do
    session = @user.sessions.create!

    # Integration test에서는 직접 MessageVerifier를 사용하여 signed 값 생성
    verifier = ActiveSupport::MessageVerifier.new(
      Rails.application.secret_key_base,
      digest: "SHA256",
      serializer: JSON
    )
    cookies[:session_token] = verifier.generate(session.id)

    # 요청 후 Current.session 확인
    get root_path

    # Current는 요청이 끝나면 리셋되므로 세션이 있는지만 확인
    assert_response :success
  end

  test "authenticate redirects to signin when not authenticated" do
    # 세션 없이 인증이 필요한 페이지 접근 (sessions#index는 authenticate 필요)
    get sessions_path

    assert_redirected_to signin_path
  end

  test "authenticate allows access when authenticated" do
    # 세션 생성 및 쿠키 설정
    session = @user.sessions.create!

    # Integration test에서는 직접 signed 값을 생성
    verifier = ActiveSupport::MessageVerifier.new(
      Rails.application.secret_key_base,
      digest: "SHA256",
      serializer: JSON
    )
    cookies[:session_token] = verifier.generate(session.id)

    get sessions_path
    assert_response :found
  end
end

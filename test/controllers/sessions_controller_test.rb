require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admins(:one)
    # rate_limit 카운터는 캐시에 IP 별로 쌓인다. 테스트 요청이 모두 127.0.0.1
    # 에서 오므로 비워 두지 않으면 앞선 테스트의 실패 시도가 다음 테스트를 429 로 만든다.
    Rails.cache.clear
  end

  test "should get login page" do
    get login_url
    assert_response :success
  end

  # 로그인 화면은 content_for :title 을 설정하지 않는 유일한 뷰라
  # 레이아웃의 기본 제목 폴백이 실제로 동작하는지 확인할 수 있는 자리다.
  test "login page falls back to the default title" do
    get login_url
    assert_select "title", text: /Kamil Lee/
  end

  test "should redirect to root when already logged in" do
    post login_url, params: { email: @admin.email, password: "password" }
    get login_url
    assert_redirected_to root_path
  end

  test "should login with correct credentials" do
    post login_url, params: { email: @admin.email, password: "password" }
    assert_redirected_to root_path
    assert_equal @admin.id, session[:admin_id]
    assert_not_nil session[:admin_logged_in_at]
  end

  test "should reject incorrect password" do
    post login_url, params: { email: @admin.email, password: "wrong_password" }
    assert_response :unprocessable_entity
  end

  test "should reject incorrect email" do
    post login_url, params: { email: "unknown@example.com", password: "password" }
    assert_response :unprocessable_entity
  end

  test "should logout" do
    post login_url, params: { email: @admin.email, password: "password" }
    delete logout_url
    assert_redirected_to root_path
  end

  test "should lockout after max attempts" do
    SessionsController::MAX_LOGIN_ATTEMPTS.times do
      post login_url, params: { email: @admin.email, password: "wrong" }
    end

    # Next attempt should be locked out
    post login_url, params: { email: @admin.email, password: "wrong" }
    assert_response :too_many_requests
  end

  # 예전 잠금은 시도 횟수를 세션(=쿠키)에 뒀기 때문에 공격자가 쿠키를 버리면
  # 매번 새 세션이 되어 무제한으로 시도할 수 있었다. 이 테스트가 그 회귀를 막는다.
  test "throttling survives a client that throws its cookies away" do
    SessionsController::MAX_LOGIN_ATTEMPTS.times do
      post login_url, params: { email: @admin.email, password: "wrong" }
      reset! # 쿠키를 포함한 세션을 통째로 버리고 새 클라이언트로 시작한다
    end

    post login_url, params: { email: @admin.email, password: "wrong" }
    assert_response :too_many_requests
  end

  # 스로틀에 걸린 뒤에도 올바른 비밀번호면 통과해 버리면 의미가 없다.
  test "throttling blocks even a valid password once the limit is hit" do
    SessionsController::MAX_LOGIN_ATTEMPTS.times do
      post login_url, params: { email: @admin.email, password: "wrong" }
    end

    post login_url, params: { email: @admin.email, password: "password" }
    assert_response :too_many_requests
    assert_nil session[:admin_id]
  end

  test "should show remaining attempts on failed login" do
    post login_url, params: { email: @admin.email, password: "wrong" }
    assert_response :unprocessable_entity
    remaining = SessionsController::MAX_LOGIN_ATTEMPTS - 1
    assert_match /#{remaining} attempt/, flash[:alert]
  end
end

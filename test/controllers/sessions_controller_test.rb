require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "should get login page" do
    get login_url
    assert_response :success
  end

  test "should redirect to root when already logged in" do
    post login_url, params: { password: (ENV["ADMIN_PASSWORD"] || "password") }
    get login_url
    assert_redirected_to root_path
  end

  test "should login with correct password" do
    post login_url, params: { password: (ENV["ADMIN_PASSWORD"] || "password") }
    assert_redirected_to root_path
    assert_equal "admin", session[:admin_id]
  end

  test "should reject incorrect password" do
    post login_url, params: { password: "wrong_password" }
    assert_response :unprocessable_entity
  end

  test "should logout" do
    post login_url, params: { password: (ENV["ADMIN_PASSWORD"] || "password") }
    delete logout_url
    assert_redirected_to root_path
  end

  test "should lockout after max attempts" do
    SessionsController::MAX_LOGIN_ATTEMPTS.times do
      post login_url, params: { password: "wrong" }
    end

    # Next attempt should be locked out
    post login_url, params: { password: "wrong" }
    assert_response :too_many_requests
  end

  test "should show remaining attempts on failed login" do
    post login_url, params: { password: "wrong" }
    assert_response :unprocessable_entity
    remaining = SessionsController::MAX_LOGIN_ATTEMPTS - 1
    assert_match /#{remaining} attempt/, flash[:alert]
  end
end

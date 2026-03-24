require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admins(:one)
  end

  test "should get login page" do
    get login_url
    assert_response :success
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

  test "should show remaining attempts on failed login" do
    post login_url, params: { email: @admin.email, password: "wrong" }
    assert_response :unprocessable_entity
    remaining = SessionsController::MAX_LOGIN_ATTEMPTS - 1
    assert_match /#{remaining} attempt/, flash[:alert]
  end
end

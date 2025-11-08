require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get signup_url
    assert_response :success
  end

  test "should sign up with JSON" do
    assert_difference("User.count") do
      post signup_url, params: { user: { email: "newuser@example.com", nickname: "New User" } }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert json_response["success"]
    assert_equal "newuser@example.com", json_response["email"]
  end
end

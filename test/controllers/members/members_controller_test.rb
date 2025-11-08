require "test_helper"

class Members::MembersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:lazaro_nixon)
  end

  test "should get current user data when authenticated" do
    sign_in_as @user

    get members_api_member_url, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal @user.email, json_response["email"]
    assert_equal @user.nickname, json_response["name"]
    assert_equal @user.enable_newsletter_notifications, json_response["enable_newsletter_notifications"]
  end

  test "should return unauthorized when not authenticated" do
    get members_api_member_url, as: :json

    assert_response :unauthorized
  end

  test "should update newsletter preferences" do
    sign_in_as @user

    put members_api_member_url, params: {
      user: {
        enable_newsletter_notifications: true
      }
    }, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response["enable_newsletter_notifications"]

    @user.reload
    assert @user.enable_newsletter_notifications
  end

  test "should update nickname" do
    sign_in_as @user

    put members_api_member_url, params: {
      user: {
        nickname: "New Nickname"
      }
    }, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "New Nickname", json_response["name"]

    @user.reload
    assert_equal "New Nickname", @user.nickname
  end

  test "should update email and set verified to false" do
    sign_in_as @user

    put members_api_member_url, params: {
      user: {
        email: "newemail@example.com"
      }
    }, as: :json

    assert_response :success
    json_response = JSON.parse(response.body)
    assert_equal "newemail@example.com", json_response["email"]
    assert_not json_response["verified"]

    @user.reload
    assert_equal "newemail@example.com", @user.email
    assert_not @user.verified
  end

  test "should not update with invalid email" do
    sign_in_as @user

    put members_api_member_url, params: {
      user: {
        email: "invalid-email"
      }
    }, as: :json

    assert_response :unprocessable_entity
  end

  test "should not update with duplicate email" do
    sign_in_as @user
    other_user = users(:unverified_user)

    put members_api_member_url, params: {
      user: {
        email: other_user.email
      }
    }, as: :json

    assert_response :unprocessable_entity
  end
end

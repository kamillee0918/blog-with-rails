require "test_helper"

class ApplicationControllerTest < ActionDispatch::IntegrationTest
  class TestController < ApplicationController
    def trigger_not_found
      raise ActiveRecord::RecordNotFound
    end

    def trigger_bad_request
      raise ActionController::ParameterMissing, :email
    end

    def trigger_unprocessable_entity
      raise ActiveRecord::RecordInvalid
    end

    def test_set_session_cookie
      session = Session.create!(user: users(:verified_user))
      set_session_cookie(session)
      head :ok
    end

    def test_delete_session_cookie
      delete_session_cookie
      head :ok
    end
  end

  setup do
    # 테스트용 라우트 추가
    Rails.application.routes.draw do
      get "test/not_found", to: "application_controller_test/test#trigger_not_found"
      get "test/bad_request", to: "application_controller_test/test#trigger_bad_request"
      get "test/unprocessable_entity", to: "application_controller_test/test#trigger_unprocessable_entity"
      get "test/set_session_cookie", to: "application_controller_test/test#test_set_session_cookie"
      get "test/delete_session_cookie", to: "application_controller_test/test#test_delete_session_cookie"
    end
  end

  teardown do
    Rails.application.reload_routes!
  end

  test "rescue_from handles RecordNotFound with JSON" do
    get test_not_found_path, as: :json

    assert_response :not_found
    json_response = JSON.parse(response.body)
    assert_equal "Not found", json_response["error"]
  end

  test "rescue_from handles ParameterMissing with JSON" do
    get test_bad_request_path, as: :json

    assert_response :bad_request
    json_response = JSON.parse(response.body)
    assert_equal "Bad request", json_response["error"]
  end

  test "rescue_from handles RecordInvalid with JSON" do
    get test_unprocessable_entity_path, as: :json

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert_equal "Unprocessable entity", json_response["error"]
  end
end

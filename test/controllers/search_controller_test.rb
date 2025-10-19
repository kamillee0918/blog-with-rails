require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  test "should return json results when format is json" do
    get search_url(format: :json, q: "test")
    assert_response :success
    assert_equal "application/json; charset=utf-8", response.content_type
  end

  test "should return empty results for blank query" do
    get search_url(format: :json, q: "")
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal 0, json_response["total"]
    assert_empty json_response["posts"]
  end
end

require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  test "should get show with category name" do
    get category_url("development")
    assert_response :success
  end
end

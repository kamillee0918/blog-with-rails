require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  test "should render 404 page without error" do
    get "/404"
    assert_response :success
  end

  test "should render 422 page without error" do
    get "/422"
    assert_response :success
  end

  test "should render 500 page without error" do
    get "/500"
    assert_response :success
  end

  test "404 page displays popular tags" do
    tag = Tag.create!(name: "ruby")
    post = Post.create!(title: "Test", published_at: Time.current, category: "Test")
    post.tags << tag

    get "/404"
    assert_response :success
  end
end

require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "should get show with valid slug" do
    # Post가 존재하지 않는 경우를 대비해 404 응답 확인
    get post_by_slug_url("sample-post")
    assert_response :not_found
  end
end

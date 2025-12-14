require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
    # Mock admin login
    post login_url, params: { password: (ENV["ADMIN_PASSWORD"] || "password") }
    assert_response :redirect
  end

  test "should get index" do
    get posts_url
    assert_response :success
  end

  test "should get new" do
    get new_post_url
    assert_response :success
  end

  test "should create post" do
    assert_difference("Post.count") do
      post posts_url, params: { post: { published_at: @post.published_at, summary: @post.summary, title: "New Post", category: "Tech" } }
    end

    assert_redirected_to post_url(Post.last)
  end

  test "should show post" do
    get post_url(@post)
    assert_response :success
  end

  test "should get edit" do
    get edit_post_url(@post)
    assert_response :success
  end

  test "should update post" do
    patch post_url(@post), params: { post: { published_at: @post.published_at, summary: @post.summary, title: @post.title, category: "Updated Category" } }
    assert_redirected_to post_url(@post)
  end

  test "should destroy post" do
    assert_difference("Post.count", -1) do
      delete post_url(@post)
    end

    assert_redirected_to posts_url
  end

  test "should filter by category" do
    get posts_url(category: "Tech")
    assert_response :success
    # The first post uses tts-entry__title, subsequent ones use ts-entry__title
    assert_select "h2", text: @post.title
  end
end

require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
    @admin = admins(:one)
    # Mock admin login
    post login_url, params: { email: @admin.email, password: "password" }
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

  test "show renders a link to the post's category" do
    get post_url(@post)
    assert_select "a.ts-category-link[href=?]", category_posts_path(category: @post.category),
                  text: @post.category
  end

  # 클립보드 스크립트가 이 훅으로 알림을 찾는다. 클래스만 있고 속성이 없으면
  # 복사는 되지만 "Copied!" 가 뜨지 않는다.
  test "show exposes the share notification hook" do
    get post_url(@post)
    assert_select "[data-share-notification]"
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

  test "관리자는 미공개(예약) 게시글을 볼 수 있다" do
    scheduled = Post.create!(title: "Scheduled Admin View", published_at: 1.day.from_now, category: "Test")

    get post_url(scheduled)
    assert_response :success
  end

  test "비로그인 방문자는 미공개(예약) 게시글에 접근할 수 없다" do
    delete logout_url
    scheduled = Post.create!(title: "Scheduled Post", published_at: 1.day.from_now, category: "Test")

    get post_url(scheduled)
    assert_response :not_found
  end

  test "비로그인 방문자의 사이드바에 미공개 게시글이 노출되지 않는다" do
    delete logout_url
    Post.create!(title: "Secret Upcoming Post", published_at: 1.day.from_now, category: "Test")
    visible = Post.create!(title: "Visible Post", published_at: 1.day.ago, category: "Test")

    get post_url(visible)
    assert_response :success
    assert_no_match(/Secret Upcoming Post/, response.body)
  end

  test "should filter by category" do
    get posts_url(category: "Tech")
    assert_response :success
    # The first post uses tts-entry__title, subsequent ones use ts-entry__title
    assert_select "h2", text: @post.title
  end
end

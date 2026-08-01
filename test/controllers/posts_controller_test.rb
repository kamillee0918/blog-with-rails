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

  # after_action 이 Cache-Control 을 직접 쓰면 Rails 가 커밋 시점에 넣는 기본값이
  # 적용되지 않는다. no-transform 만 남으면 캐시가 휴리스틱 신선도로 떨어져
  # 오래된 글일수록 재검증 없이 오래 캐시된다.
  test "public HTML keeps the conditional GET directives next to no-transform" do
    delete logout_url
    get post_url(@post)

    cache_control = response.headers["Cache-Control"]
    assert_includes cache_control, "no-transform"
    assert_includes cache_control, "must-revalidate"
    assert_includes cache_control, "private"
    assert_not_includes cache_control, "no-store"
  end

  test "admin HTML stays uncacheable" do
    get post_url(@post)
    assert_includes response.headers["Cache-Control"], "no-store"
  end

  # 페이지네이션된 relation 에 maximum(:updated_at) 을 쓰면 LIMIT/OFFSET 이 붙어
  # 2페이지부터 nil 이 되어 헤더가 사라졌다.
  test "paginated index is cacheable beyond the first page" do
    delete logout_url
    get posts_path(page: 2)

    assert_response :success
    assert_not_nil response.headers["ETag"]
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

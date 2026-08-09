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

  # 조건부 GET 이 실제로 동작한다는 증거는 두 번째 요청이 304 를 받는 것뿐이다.
  # relation 을 그대로 etag 로 넘기면 published 스코프의 Time.current 가 to_sql 에
  # 박혀 매 요청 ETag 가 달라지고, 이 테스트가 실패한다.
  test "index answers 304 when nothing changed" do
    delete logout_url
    # ActionController::EtagWithFlash 가 flash 를 ETag 에 섞는다. 로그아웃 직후
    # 응답에는 "Logged out." 이 실려 있어 ETag 가 다를 수밖에 없으므로,
    # 여기서 한 번 소비시켜 flash 없는 상태에서 비교한다.
    get posts_url

    get posts_url
    assert_response :success
    etag = response.headers["ETag"]
    assert_not_nil etag, "ETag 헤더가 없다"

    get posts_url
    assert_equal etag, response.headers["ETag"],
                 "내용이 같은데 ETag 가 달라졌다 (validator 가 불안정)"

    get posts_url, headers: { "If-None-Match" => etag }
    assert_response :not_modified
  end

  # 위 테스트는 파라미터 없는 /posts 만 본다. 그 경로는 show_all 을 렌더하지 않아
  # 두 번째 렌더가 일어나지 않고, 그래서 아래 버그를 놓쳤다.
  # fresh_when 은 304 를 렌더하지만 액션을 중단하지 않는다. category/page 가 붙으면
  # 그 뒤의 render :show_all 이 두 번째 렌더가 되어 DoubleRenderError → 500 이 된다.
  # 즉 카테고리 페이지와 페이지네이션은 재방문자에게 전부 500 이었다.
  test "category listing answers 304 instead of raising DoubleRenderError" do
    delete logout_url
    get posts_url(category: posts(:one).category)

    get posts_url(category: posts(:one).category)
    assert_response :success
    etag = response.headers["ETag"]
    assert_not_nil etag, "ETag 헤더가 없다"

    get posts_url(category: posts(:one).category), headers: { "If-None-Match" => etag }
    assert_response :not_modified
  end

  test "paginated listing answers 304 instead of raising DoubleRenderError" do
    delete logout_url
    get posts_url(page: 1)

    get posts_url(page: 1)
    assert_response :success
    etag = response.headers["ETag"]
    assert_not_nil etag, "ETag 헤더가 없다"

    get posts_url(page: 1), headers: { "If-None-Match" => etag }
    assert_response :not_modified
  end

  # 304 로 끊더라도 신선하지 않은 요청은 계속 목록을 렌더해야 한다.
  # assert_template 은 rails-controller-testing 젬이 있어야 쓸 수 있는데 이 앱에는 없다.
  # 대신 본문에 해당 카테고리 글이 실려 나오는지로 확인한다.
  test "category listing still renders the listing when the ETag does not match" do
    delete logout_url
    get posts_url(category: posts(:one).category), headers: { "If-None-Match" => "W/\"stale\"" }

    assert_response :success
    assert_match posts(:one).title, response.body
  end

  test "index ETag changes once a post is edited" do
    delete logout_url
    get posts_url
    etag = response.headers["ETag"]

    travel 1.second do
      posts(:one).update!(title: "Edited after the first render")
    end

    get posts_url, headers: { "If-None-Match" => etag }
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

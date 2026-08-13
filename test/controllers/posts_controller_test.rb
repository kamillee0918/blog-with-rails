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

  # 카테고리는 경로형(/posts/category/PAST)과 쿼리형(?category=PAST) 두 입구가 같은
  # index 액션을 타고 둘 다 params[:category] 로 읽힌다. 위 테스트는 쿼리형만 보므로
  # 링크가 실제로 쓰는 경로형도 함께 확인한다.
  test "path-form category listing answers 304 instead of raising DoubleRenderError" do
    delete logout_url
    get category_posts_path(category: posts(:one).category)

    get category_posts_path(category: posts(:one).category)
    assert_response :success
    etag = response.headers["ETag"]
    assert_not_nil etag, "ETag 헤더가 없다"

    get category_posts_path(category: posts(:one).category), headers: { "If-None-Match" => etag }
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

  # === 존재하지 않는 카테고리 · 태그 · 연도 ===
  #
  # 이 셋은 열거 가능한 값이고 링크로만 도달한다. 매칭이 0건이라는 것은 잘못된 URL 을
  # 받았다는 뜻이므로 빈 목록 대신 404 를 낸다. 검색은 반대다 — 사용자가 자유롭게
  # 입력하는 값이라 "찾을 수 없습니다" 안내를 렌더한다(아래 검색 테스트 참고).

  test "존재하지 않는 카테고리는 404 다" do
    delete logout_url
    get category_posts_path(category: "NoSuchCategory")

    assert_response :not_found
  end

  test "존재하지 않는 카테고리는 쿼리형으로 와도 404 다" do
    delete logout_url
    get posts_path(category: "NoSuchCategory")

    assert_response :not_found
  end

  test "존재하지 않는 태그는 404 다" do
    delete logout_url
    get tag_posts_path(tag: "no-such-tag")

    assert_response :not_found
  end

  test "게시글이 없는 연도의 아카이브는 404 다" do
    delete logout_url
    get archive_posts_path(year: 2022)

    assert_response :not_found
  end

  test "글이 있는 카테고리 · 태그 · 연도는 그대로 200 이다" do
    delete logout_url
    post = posts(:one)
    post.tag_list = "archive-probe"

    get category_posts_path(category: post.category)
    assert_response :success

    get tag_posts_path(tag: "archive-probe")
    assert_response :success

    get archive_posts_path(year: post.published_at.year)
    assert_response :success
  end

  test "필터가 없는 목록은 404 로 바뀌지 않는다" do
    delete logout_url
    get posts_path

    assert_response :success
  end

  # post_scope 가 관리자 여부로 갈리므로, 미공개 글만 있는 카테고리는 방문자에게는
  # 없는 것과 같고 관리자에게는 보여야 한다.
  test "미공개 글만 있는 카테고리는 방문자에게 404, 관리자에게는 200 이다" do
    Post.create!(title: "Draft Only", published_at: 1.day.from_now, category: "DraftOnly")

    delete logout_url
    get category_posts_path(category: "DraftOnly")
    assert_response :not_found

    sign_in_as_admin
    get category_posts_path(category: "DraftOnly")
    assert_response :success
  end

  # === 검색 ===

  # 정식 검색 URL 은 경로형(/search/키워드)이다. 그런데 HTML 의 GET 폼은 입력을 항상
  # 쿼리스트링으로만 직렬화하므로 /search/?keyword=x 밖에 만들 수 없고, 그 형태에
  # 라우트가 없어 404 가 났다. 사이드바·검색결과·404 페이지의 검색창이 전부 그랬다.
  test "search accepts the query form a plain GET form produces" do
    get "/search", params: { keyword: "past" }

    assert_redirected_to search_path(keyword: "past")
  end

  test "search redirect encodes keywords that need it" do
    get "/search", params: { keyword: "build tools" }

    assert_redirected_to search_path(keyword: "build tools")
    assert_match "build%20tools", response.headers["Location"]
  end

  test "search redirect sends an empty keyword back to the listing" do
    get "/search", params: { keyword: "  " }

    assert_redirected_to posts_path
  end

  test "search redirect survives a missing keyword" do
    get "/search"

    assert_redirected_to posts_path
  end

  # 경로형은 그대로 동작해야 한다 — 기존 링크와 북마크가 여기에 걸려 있다.
  test "canonical search path still renders results" do
    get search_path(keyword: posts(:one).title.split.first)

    assert_response :success
  end

  # 결과가 0건일 때만 타는 분기에 order('COUNT(*) DESC') 가 있어, "찾을 수 없습니다"
  # 안내를 보여 주려던 자리가 정작 500 을 냈다. 결과가 있는 검색은 이 분기를 타지
  # 않으므로 오래 눈에 띄지 않았다.
  test "search with no results renders the empty state instead of raising" do
    get search_path(keyword: "zzzznomatchzzzz")

    assert_response :success
    assert_match "cannot find", response.body
  end

  # 라우트만 고치면 폼이 엉뚱한 곳을 가리켜도 통과한다. 검색창이 실제로 살아 있는
  # 페이지들에서 폼의 action 이 그 라우트를 가리키는지까지 확인한다.
  test "every rendered search form posts to a route that exists" do
    delete logout_url

    { "상세 페이지(사이드바)" => post_url(posts(:one)),
      "검색 결과" => search_path(keyword: "past"),
      "목록" => posts_url }.each do |label, url|
      get url
      assert_response :success, label

      actions = response.body.scan(/<form[^>]*action="([^"]*search[^"]*)"/i).flatten.uniq
      assert_not_empty actions, "#{label}: 검색 폼이 없다"
      actions.each do |action|
        assert_equal search_query_path, action,
                     "#{label}: 폼이 #{action} 로 제출한다 — GET 폼은 쿼리스트링만 만들 수 있다"
      end
    end
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

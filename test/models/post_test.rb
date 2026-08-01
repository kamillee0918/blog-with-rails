require "test_helper"

class PostTest < ActiveSupport::TestCase
  # === Validation Tests ===
  test "should not save post without title" do
    post = Post.new(published_at: Time.current, category: "Test")
    assert_not post.save, "Saved the post without a title"
  end

  test "should not save post without category" do
    post = Post.new(title: "No Category", published_at: Time.current)
    assert_not post.save, "Saved the post without a category"
  end

  test "should not save post without published_at" do
    post = Post.new(title: "No Date", category: "Test")
    assert_not post.save, "Saved the post without published_at"
  end

  # === Slug Generation Tests ===
  test "should generate slug from english title" do
    post = Post.create!(title: "Hello World", published_at: Time.current, category: "Test")
    assert_equal "hello-world", post.slug
  end

  test "should not generate slug from korean title" do
    post = Post.create!(title: "안녕하세요", published_at: Time.current, category: "Test")
    assert_nil post.slug, "Korean title should have nil slug"
  end

  test "should preserve manually set slug" do
    post = Post.create!(title: "Some Title", slug: "custom-slug", published_at: Time.current, category: "Test")
    assert_equal "custom-slug", post.slug
  end

  # === to_param Tests ===
  test "to_param returns slug when present" do
    post = Post.create!(title: "English Title", published_at: Time.current, category: "Test")
    assert_equal "english-title", post.to_param
  end

  test "to_param returns id when slug is nil" do
    post = Post.create!(title: "한국어 제목", published_at: Time.current, category: "Test")
    assert_equal post.id.to_s, post.to_param
  end

  # === find_by_slug_or_id Tests ===
  test "find_by_slug_or_id finds by slug" do
    post = Post.create!(title: "Find Me", published_at: Time.current, category: "Test")
    found = Post.find_by_slug_or_id("find-me")
    assert_equal post, found
  end

  test "find_by_slug_or_id finds by id" do
    post = Post.create!(title: "한국어", published_at: Time.current, category: "Test")
    found = Post.find_by_slug_or_id(post.id)
    assert_equal post, found
  end

  test "find_by_slug_or_id! raises when not found" do
    assert_raises(ActiveRecord::RecordNotFound) do
      Post.find_by_slug_or_id!("non-existent")
    end
  end

  # === Scope Tests ===
  test "search scope finds by title" do
    post = Post.create!(title: "Unique Searchable Title", published_at: Time.current, category: "Test")
    results = Post.search("Searchable")
    assert_includes results, post
  end

  test "search scope returns none for blank query" do
    Post.create!(title: "Some Post", published_at: Time.current, category: "Test")
    results = Post.search("")
    assert_empty results
  end

  test "by_year scope filters by year" do
    post_2024 = Post.create!(title: "Post 2024", published_at: Time.new(2024, 6, 1), category: "Test")
    post_2025 = Post.create!(title: "Post 2025", published_at: Time.new(2025, 6, 1), category: "Test")

    results = Post.by_year(2024)
    assert_includes results, post_2024
    assert_not_includes results, post_2025
  end

  # === Instance Method Tests ===
  test "previous_post returns earlier post" do
    # 과거 날짜를 사용 (.published 스코프가 미래 게시글을 제외하므로)
    older = Post.create!(title: "Older Nav", published_at: 3.days.ago, category: "Test")
    newer = Post.create!(title: "Newer Nav", published_at: 2.days.ago, category: "Test")

    assert_equal older, newer.previous_post
  end

  test "next_post returns later post" do
    # 과거 날짜를 사용 (.published 스코프가 미래 게시글을 제외하므로)
    older = Post.create!(title: "Older Nav2", published_at: 4.days.ago, category: "Test")
    newer = Post.create!(title: "Newer Nav2", published_at: 3.days.ago, category: "Test")

    assert_equal newer, older.next_post
  end

  test "recommended_posts returns posts with matching tags" do
    ruby_tag = Tag.create!(name: "ruby")
    rails_tag = Tag.create!(name: "rails")
    python_tag = Tag.create!(name: "python")
    js_tag = Tag.create!(name: "javascript")

    post1 = Post.create!(title: "Post 1", published_at: Time.current, category: "Test")
    post1.tags << ruby_tag << rails_tag
    post2 = Post.create!(title: "Post 2", published_at: Time.current, category: "Test")
    post2.tags << ruby_tag << python_tag
    post3 = Post.create!(title: "Post 3", published_at: Time.current, category: "Test")
    post3.tags << js_tag

    recommended = post1.recommended_posts
    assert_includes recommended, post2
    assert_not_includes recommended, post3
  end

  test "recommended_posts returns empty when no tags" do
    post = Post.create!(title: "No Tags", published_at: Time.current, category: "Test")
    assert_empty post.recommended_posts
  end

  test "tag_list getter returns comma-separated names" do
    post = Post.create!(title: "Tagged", published_at: Time.current, category: "Test")
    post.tags << Tag.create!(name: "ruby") << Tag.create!(name: "rails")
    assert_equal "ruby, rails", post.tag_list
  end

  test "tag_list setter creates and assigns tags" do
    post = Post.create!(title: "Tagged2", published_at: Time.current, category: "Test")
    post.tag_list = "ruby, rails, ruby"
    assert_equal 2, post.tags.count
    assert_equal %w[ruby rails], post.tags.pluck(:name).sort_by { |n| %w[ruby rails].index(n) }
  end

  # HABTM 할당은 posts_tags 만 바꾸므로 태그만 수정하면 posts.updated_at 이 그대로다.
  # 그러면 ETag/cache_version 이 바뀌지 않아 독자가 옛 태그를 계속 보게 된다.
  test "changing the tag list touches the post so caches revalidate" do
    post = Post.create!(title: "Retagged", published_at: Time.current, category: "Test")
    post.update!(tag_list: "ruby, rails")
    before = post.reload.updated_at

    travel 1.second do
      post.update!(tag_list: "ruby, rails, hotwire")
    end

    assert_operator post.reload.updated_at, :>, before
  end

  test "reassigning the same tags leaves updated_at alone" do
    post = Post.create!(title: "Same tags", published_at: Time.current, category: "Test")
    post.update!(tag_list: "ruby, rails")
    before = post.reload.updated_at

    travel 1.second do
      post.update!(tag_list: "rails, ruby")
    end

    assert_equal before, post.reload.updated_at
  end

  # 인코딩 정규식보다 디코딩 정규식이 넓어, 저장 시 인코딩되지 않은 코드 블록이
  # 렌더 시점에는 매칭되는 경우가 있다. 예전에는 strict_decode64 가 ArgumentError 를
  # 던져 해당 게시글이 모든 방문자에게 500 이 됐다.
  test "rendered_content survives a code block that is not valid Base64" do
    post = Post.create!(title: "Broken block", published_at: Time.current, category: "Test",
                        content: "<pre><code>BASE64:abc</code></pre>")

    rendered = nil
    assert_nothing_raised { rendered = post.rendered_content }
    assert_includes rendered.to_s, "BASE64:abc"
  end

  test "rendered_content still decodes a well-formed code block" do
    encoded = Base64.strict_encode64("puts &lt;%= 1 %&gt;")
    post = Post.create!(title: "Good block", published_at: Time.current, category: "Test",
                        content: "<pre><code>BASE64:#{encoded}</code></pre>")

    assert_includes post.rendered_content.to_s, "puts &lt;%= 1 %&gt;"
  end

  test "read_time returns minimum 1 min for empty content" do
    post = Post.create!(title: "Empty", published_at: Time.current, category: "Test")
    assert_equal "1 min read", post.read_time
  end

  test "word_count is stored on save so read_time never parses the body" do
    post = Post.create!(title: "Counted", published_at: Time.current, category: "Test",
                        content: "<div>#{Array.new(360) { 'word' }.join(' ')}</div>")

    assert_equal 360, post.reload.word_count
    assert_equal "2 min read", post.read_time
  end

  test "word_count follows edits to the body" do
    post = Post.create!(title: "Recount", published_at: Time.current, category: "Test",
                        content: "<div>one two three</div>")
    assert_equal 3, post.reload.word_count

    post.update!(content: "<div>#{Array.new(200) { 'word' }.join(' ')}</div>")
    assert_equal 200, post.reload.word_count
  end

  # 목록 카드가 본문을 건드리지 않아야 listing_scope 에서 rich text 를 뺀 의미가 있다.
  test "read_time does not load the rich text association" do
    Post.create!(title: "No body load", published_at: Time.current, category: "Test",
                 content: "<div>one two three</div>")
    post = Post.where(title: "No body load").first

    post.read_time

    assert_not post.association(:rich_text_content).loaded?
  end

  test "published scope excludes future posts" do
    past = Post.create!(title: "Past", published_at: 1.day.ago, category: "Test")
    future = Post.create!(title: "Future", published_at: 1.day.from_now, category: "Test")

    results = Post.published
    assert_includes results, past
    assert_not_includes results, future
  end

  test "previous_post excludes unpublished future posts" do
    past = Post.create!(title: "Past Nav", published_at: 5.days.ago, category: "Test")
    current = Post.create!(title: "Current Nav", published_at: 3.days.ago, category: "Test")
    future = Post.create!(title: "Future Nav", published_at: 1.day.from_now, category: "Test")

    # future post should not appear as next_post for current
    assert_nil current.next_post || (current.next_post != future ? nil : current.next_post)
  end

  test "recommended_posts excludes unpublished posts" do
    shared = Tag.create!(name: "shared-topic")
    base = Post.create!(title: "Rec Base", published_at: 2.days.ago, category: "Test")
    base.tags << shared
    future = Post.create!(title: "Rec Future", published_at: 1.day.from_now, category: "Test")
    future.tags << shared

    assert_not_includes base.recommended_posts, future
  end

  test "find_by_slug_or_id respects the current scope" do
    future = Post.create!(title: "Scoped Future", published_at: 1.day.from_now, category: "Test")

    assert_equal future, Post.find_by_slug_or_id("scoped-future")
    assert_nil Post.published.find_by_slug_or_id("scoped-future")
  end

  # === Active Storage variant Tests ===
  # 이미지 백엔드 젬(ruby-vips) 누락 같은 회귀는 정적 분석으로 잡히지 않으므로
  # 실제로 variant를 생성해 확인한다.
  test "cover_image variant를 실제로 생성할 수 있다" do
    post = Post.create!(title: "With Cover", published_at: Time.current, category: "Test")
    post.cover_image.attach(
      io: file_fixture("test_image.png").open,
      filename: "test_image.png",
      content_type: "image/png"
    )

    processed = post.cover_image.variant(resize_to_limit: [ 32, 32 ], format: :webp).processed

    assert_operator processed.image.blob.byte_size, :>, 0
  end

  test "by_tag scope finds posts by normalized tag" do
    tag = Tag.create!(name: "ruby")
    post = Post.create!(title: "Ruby Post", published_at: Time.current, category: "Test")
    post.tags << tag

    results = Post.by_tag("Ruby")
    assert_includes results, post
  end
end

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

  test "read_time returns minimum 1 min for empty content" do
    post = Post.create!(title: "Empty", published_at: Time.current, category: "Test")
    assert_equal "1 min read", post.read_time
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

  test "by_tag scope finds posts by normalized tag" do
    tag = Tag.create!(name: "ruby")
    post = Post.create!(title: "Ruby Post", published_at: Time.current, category: "Test")
    post.tags << tag

    results = Post.by_tag("Ruby")
    assert_includes results, post
  end
end

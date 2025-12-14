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
    # 미래 날짜를 사용하여 fixture 데이터와 충돌 방지
    older = Post.create!(title: "Older Nav", published_at: 10.days.from_now, category: "Test")
    newer = Post.create!(title: "Newer Nav", published_at: 11.days.from_now, category: "Test")

    assert_equal older, newer.previous_post
  end

  test "next_post returns later post" do
    # 미래 날짜를 사용하여 fixture 데이터와 충돌 방지
    older = Post.create!(title: "Older Nav2", published_at: 20.days.from_now, category: "Test")
    newer = Post.create!(title: "Newer Nav2", published_at: 21.days.from_now, category: "Test")

    assert_equal newer, older.next_post
  end

  test "recommended_posts returns posts with matching tags" do
    post1 = Post.create!(title: "Post 1", tags: "ruby, rails", published_at: Time.current, category: "Test")
    post2 = Post.create!(title: "Post 2", tags: "ruby, python", published_at: Time.current, category: "Test")
    post3 = Post.create!(title: "Post 3", tags: "javascript", published_at: Time.current, category: "Test")

    recommended = post1.recommended_posts
    assert_includes recommended, post2
    assert_not_includes recommended, post3
  end

  test "recommended_posts returns empty when no tags" do
    post = Post.create!(title: "No Tags", published_at: Time.current, category: "Test")
    assert_empty post.recommended_posts
  end
end

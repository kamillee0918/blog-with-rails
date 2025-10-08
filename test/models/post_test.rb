require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "should not save post without title" do
    post = Post.new(slug: "test-slug", content: "Test content", category: "AI")
    assert_not post.save, "Saved the post without a title"
  end

  test "should not save post without slug" do
    post = Post.new(title: "Test Title", content: "Test content", category: "AI")
    assert_not post.save, "Saved the post without a slug"
  end

  test "should not save post without content" do
    post = Post.new(title: "Test Title", slug: "test-slug", category: "AI")
    assert_not post.save, "Saved the post without content"
  end

  test "should not save post without category" do
    post = Post.new(title: "Test Title", slug: "test-slug", content: "Test content")
    assert_not post.save, "Saved the post without a category"
  end

  test "should not save post with duplicate slug" do
    post1 = Post.create(title: "Test 1", slug: "duplicate-slug", content: "Content 1", category: "AI")
    post2 = Post.new(title: "Test 2", slug: "duplicate-slug", content: "Content 2", category: "CS")
    assert_not post2.save, "Saved the post with duplicate slug"
  end

  test "should not save post with invalid slug format" do
    post = Post.new(title: "Test", slug: "Invalid Slug!", content: "Content", category: "AI")
    assert_not post.save, "Saved the post with invalid slug format"
  end

  test "published scope should return only published posts" do
    published_count = Post.published.count
    assert published_count > 0, "No published posts found"
    Post.published.each do |post|
      assert post.published?, "Found unpublished post in published scope"
    end
  end

  test "featured scope should return only featured posts" do
    featured_posts = Post.featured
    featured_posts.each do |post|
      assert post.featured, "Found non-featured post in featured scope"
    end
  end

  test "recent scope should order posts by published_at desc" do
    posts = Post.recent.limit(2).to_a
    if posts.size == 2
      assert posts[0].published_at >= posts[1].published_at, "Posts not ordered by published_at desc"
    end
  end

  test "published? should return true for published posts" do
    post = posts(:published_post)
    assert post.published?, "Published post returned false for published?"
  end

  test "published? should return false for future posts" do
    post = posts(:draft_post)
    assert_not post.published?, "Future post returned true for published?"
  end

  test "published? should return false for posts without published_at" do
    post = posts(:unpublished_post)
    assert_not post.published?, "Unpublished post returned true for published?"
  end

  test "to_param should return slug" do
    post = posts(:published_post)
    assert_equal post.slug, post.to_param, "to_param did not return slug"
  end
end

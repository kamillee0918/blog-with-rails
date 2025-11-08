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

  test "search scope returns all posts when query is blank" do
    assert_equal Post.count, Post.search("").count
    assert_equal Post.count, Post.search(nil).count
  end

  test "search scope finds posts by title" do
    post = posts(:published_post)
    results = Post.search(post.title)

    assert results.count > 0
    assert_includes results.pluck(:id), post.id
  end

  test "search scope finds posts by content" do
    post = posts(:published_post)
    # content에서 특정 단어 추출 (최소 3글자 이상)
    content_word = post.content&.split&.find { |word| word.length >= 3 } || post.title.split.first

    results = Post.search(content_word)
    assert results.count > 0
  end

  test "search scope is case insensitive" do
    post = posts(:published_post)

    results_lower = Post.search(post.title.downcase)
    results_upper = Post.search(post.title.upcase)

    assert_equal results_lower.pluck(:id).sort, results_upper.pluck(:id).sort
  end

  # Newsletter Notification Tests
  test "should send newsletter notification to subscribers when Kamil Lee publishes a post" do
    # Clear any existing jobs
    clear_enqueued_jobs

    # Create a verified subscriber
    subscriber = User.create!(
      email: "subscriber-#{Time.current.to_i}@example.com",
      nickname: "Subscriber",
      verified: true,
      enable_newsletter_notifications: true
    )

    # Count subscribers to verify
    subscriber_count = User.newsletter_subscribers.count

    assert_enqueued_jobs subscriber_count, only: ActionMailer::MailDeliveryJob do
      Post.create!(
        title: "New Post",
        slug: "new-post-#{Time.current.to_i}",
        content: "Content",
        category: "AI",
        author_name: "Kamil Lee",
        published_at: Time.current
      )
    end
  end

  test "should not send newsletter notification for draft posts" do
    clear_enqueued_jobs

    subscriber = User.create!(
      email: "subscriber-draft-#{Time.current.to_i}@example.com",
      nickname: "Subscriber Draft",
      verified: true,
      enable_newsletter_notifications: true
    )

    assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      Post.create!(
        title: "Draft Post",
        slug: "draft-post-#{Time.current.to_i}",
        content: "Content",
        category: "AI",
        author_name: "Kamil Lee",
        published_at: nil
      )
    end
  end

  test "should not send newsletter notification for posts by other authors" do
    clear_enqueued_jobs

    subscriber = User.create!(
      email: "subscriber-other-#{Time.current.to_i}@example.com",
      nickname: "Subscriber Other",
      verified: true,
      enable_newsletter_notifications: true
    )

    assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      Post.create!(
        title: "Other Author Post",
        slug: "other-author-post-#{Time.current.to_i}",
        content: "Content",
        category: "AI",
        author_name: "Other Author",
        published_at: Time.current
      )
    end
  end

  test "should not send newsletter notification to unverified subscribers" do
    clear_enqueued_jobs

    unverified = User.create!(
      email: "unverified-#{Time.current.to_i}@example.com",
      nickname: "Unverified",
      verified: false,
      enable_newsletter_notifications: true
    )

    assert_no_enqueued_jobs(only: ActionMailer::MailDeliveryJob) do
      Post.create!(
        title: "New Post",
        slug: "new-post-unverified-#{Time.current.to_i}",
        content: "Content",
        category: "AI",
        author_name: "Kamil Lee",
        published_at: Time.current
      )
    end
  end
end

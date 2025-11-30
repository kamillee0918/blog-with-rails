require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "should not save post without title" do
    post = Post.new
    assert_not post.save, "Saved the post without a title"
  end

  test "should generate slug from title" do
    post = Post.new(title: "Hello World", published_at: Time.now, category: "Test")
    post.save
    assert_equal "hello-world", post.slug
  end

  test "should not save post without category" do
    post = Post.new(title: "No Category", published_at: Time.now)
    assert_not post.save, "Saved the post without a category"
  end
end

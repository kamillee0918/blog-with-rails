require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "normalize_name downcases and strips whitespace" do
    tag = Tag.create!(name: "  Ruby  ")
    assert_equal "ruby", tag.name
  end

  test "validates uniqueness of name" do
    Tag.create!(name: "ruby")
    duplicate = Tag.new(name: "ruby")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end

  test "validates presence of name" do
    tag = Tag.new(name: "")
    assert_not tag.valid?
    assert_includes tag.errors[:name], "can't be blank"
  end

  test "find_or_create_by_name normalizes and finds existing" do
    original = Tag.create!(name: "rails")
    found = Tag.find_or_create_by_name("  Rails  ")
    assert_equal original, found
  end

  test "find_or_create_by_name creates new when not found" do
    assert_difference("Tag.count", 1) do
      Tag.find_or_create_by_name("newtag")
    end
  end

  test "popular_with_counts returns tags ordered by post count" do
    ruby_tag = Tag.create!(name: "ruby")
    rails_tag = Tag.create!(name: "rails")
    js_tag = Tag.create!(name: "javascript")

    post1 = Post.create!(title: "Post 1", published_at: Time.current, category: "Test")
    post1.tags << ruby_tag << rails_tag
    post2 = Post.create!(title: "Post 2", published_at: Time.current, category: "Test")
    post2.tags << ruby_tag

    results = Tag.popular_with_counts(10)
    # ruby should be first (2 posts), rails second (1 post)
    assert_equal "ruby", results.first[0]
    assert_equal 2, results.first[1]
    # javascript has no posts, should not appear
    assert_not results.map(&:first).include?("javascript")
  end
end

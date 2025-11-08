# frozen_string_literal: true

require "test_helper"

class PostAssociationTest < ActiveSupport::TestCase
  setup do
    @user = users(:john_doe)
    @post = posts(:published_post)
  end

  test "post can belong to a user" do
    @post.user = @user
    @post.save!

    assert_equal @user, @post.user
    assert_includes @user.posts, @post
  end

  test "post user is optional" do
    @post.user = nil
    assert @post.valid?
  end

  test "deleting user nullifies post user_id" do
    @post.update!(user: @user)
    assert_equal @user, @post.user

    @user.destroy
    @post.reload

    assert_nil @post.user_id
  end

  test "author_display_name returns user nickname when user exists" do
    @post.user = @user
    assert_equal @user.nickname, @post.author_display_name
  end

  test "author_display_name returns author_name when user is nil" do
    @post.user = nil
    @post.author_name = "Guest Author"
    assert_equal "Guest Author", @post.author_display_name
  end

  test "author_display_avatar returns gravatar when user exists" do
    @post.user = @user
    avatar_url = @post.author_display_avatar

    assert_includes avatar_url, "gravatar.com"
    assert_includes avatar_url, Digest::MD5.hexdigest(@user.email)
  end

  test "author_display_avatar returns author_avatar when user is nil" do
    @post.user = nil
    @post.author_avatar = "https://example.com/avatar.jpg"
    assert_equal "https://example.com/avatar.jpg", @post.author_display_avatar
  end
end

require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:lazaro_nixon)
    @otp_code = "123456"
  end

  test "magic_link_with_otp" do
    mail = UserMailer.magic_link_with_otp(@user, @otp_code)

    assert_equal "로그인 인증 코드", mail.subject
    assert_equal [ @user.email ], mail.to
    assert_match @otp_code, mail.body.encoded
  end

  test "new_post_notification" do
    post = Post.create!(
      title: "Test Post",
      slug: "test-post-#{Time.current.to_i}",
      content: "This is a test post content",
      excerpt: "Test excerpt",
      category: "AI",
      author_name: "Kamil Lee",
      published_at: Time.current
    )

    mail = UserMailer.new_post_notification(@user, post)

    assert_equal "📮 새 포스트 알림: Test Post", mail.subject
    assert_equal [ @user.email ], mail.to
    assert_match post.title, mail.body.encoded
    assert_match post.excerpt, mail.body.encoded
  end

  test "new_post_notification should include unsubscribe information" do
    post = Post.create!(
      title: "Test Post",
      slug: "test-post-#{Time.current.to_i}",
      content: "Content",
      excerpt: "Excerpt",
      category: "AI",
      author_name: "Kamil Lee",
      published_at: Time.current
    )

    mail = UserMailer.new_post_notification(@user, post)

    # Check for unsubscribe link or text
    assert_match(/구독/, mail.body.encoded)
  end
end

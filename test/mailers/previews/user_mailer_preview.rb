# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/new_post_notification
  def new_post_notification
    # 샘플 사용자 생성
    user = User.new(
      id: 1,
      email: "test@example.com",
      nickname: "Test User",
      verified: true,
      enable_newsletter_notifications: true
    )

    # 샘플 포스트 생성
    post = Post.new(
      id: 1,
      title: "Understanding Gumbel-AlphaZero: Part 1",
      slug: "2025-09-19-gumbel-alphazero-01",
      content: "This is a comprehensive guide to understanding the Gumbel-AlphaZero algorithm...",
      excerpt: "Learn about the revolutionary approach to reinforcement learning in game AI",
      category: "AI & Machine Learning",
      author_name: "Kamil Lee",
      published_at: Time.current,
      featured: true
    )

    UserMailer.new_post_notification(user, post)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/magic_link_with_otp
  def magic_link_with_otp
    user = User.new(
      email: "test@example.com",
      nickname: "Test User",
      magic_link_token: "sample_magic_link_token_123456"
    )

    UserMailer.magic_link_with_otp(user, "123456")
  end
end

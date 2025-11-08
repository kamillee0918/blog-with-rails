class UserMailer < ApplicationMailer
  # 새 포스트 알림 이메일
  # @param user [User] 수신자
  # @param post [Post] 새로 작성된 포스트
  def new_post_notification(user, post)
    @user = user
    @post = post
    @post_url = post_by_slug_url(slug: post.slug)

    # 개발 환경에서는 콘솔에 출력
    if Rails.env.development?
      Rails.logger.info "=" * 81
      Rails.logger.info "📧 New Post Notification Email"
      Rails.logger.info "To: #{user.email}"
      Rails.logger.info "User: #{user.nickname}"
      Rails.logger.info "=" * 81
      Rails.logger.info "Post Title: #{post.title}"
      Rails.logger.info "Post Content: #{post.content}"
      Rails.logger.info "Post URL: #{@post_url}"
      Rails.logger.info "=" * 81
    end

    # 배포 환경에서는 실제 이메일 발송
    mail(
      to: user.email,
      subject: "새로운 포스트: #{post.title}"
    )
  end

  def magic_link_with_otp(user, otp_code)
    @user = user
    @magic_link_url = magic_link_url(token: user.magic_link_token)
    @otp_code = otp_code

    mail(
      to: user.email,
      subject: "로그인 인증 코드"
    )
  end
end

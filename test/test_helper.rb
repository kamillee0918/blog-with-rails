ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # ActiveJob 테스트 헬퍼 포함
  include ActiveJob::TestHelper

  # Add more helper methods to be used by all tests here...
end

class ActionDispatch::IntegrationTest
  # Integration Test용 인증 헬퍼
  def sign_in_as(user)
    # Rails 가이드 방식: 실제 인증 엔드포인트를 통해 로그인
    # Magic Link를 생성하고 이를 통해 인증

    # 1. Magic link token이 있는지 확인
    user.regenerate_magic_link_token unless user.magic_link_token.present?
    user.update!(magic_link_sent_at: Time.current)

    # 2. Magic link 엔드포인트를 통해 인증
    get magic_link_url(token: user.magic_link_token)

    # 3. 리다이렉트 follow
    follow_redirect! if response.redirect?

    user
  end

  # 로그아웃 헬퍼
  def sign_out
    cookies.delete(:session_token)
  end
end

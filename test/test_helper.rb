ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  def sign_in_as(user)
    # Magic Link 방식으로 세션 생성
    session = user.sessions.create!

    # Integration test에서는 직접 MessageVerifier를 사용하여 signed 값 생성
    # Rack::Test::CookieJar는 cookies.signed를 지원하지 않음
    verifier = ActiveSupport::MessageVerifier.new(
      Rails.application.secret_key_base,
      digest: "SHA256",
      serializer: JSON
    )
    cookies[:session_token] = verifier.generate(session.id)

    user
  end
end

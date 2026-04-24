require "simplecov"
SimpleCov.start "rails" do
  enable_coverage :branch

  add_filter "/test/"
  add_filter "/config/"
  add_filter "/db/"
  add_filter "/vendor/"
  add_filter "/bin/"

  add_group "Controllers", "app/controllers"
  add_group "Models",      "app/models"
  add_group "Helpers",     "app/helpers"
  add_group "Jobs",        "app/jobs"
  add_group "Mailers",     "app/mailers"
  add_group "Channels",    "app/channels"
end

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # SimpleCov parallel-test compatibility:
    # fork된 각 워커에 고유한 command_name을 부여하여 결과 덮어쓰기 방지.
    parallelize_setup do |worker|
      SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
    end

    # 각 워커 종료 시 결과를 기록하여 SimpleCov가 자동 병합하도록 트리거.
    parallelize_teardown do |_worker|
      SimpleCov.result
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...

    # Helper: sign in as admin for controller tests.
    # 사용 예정: uploads_controller_test, 관리자 전용 posts 액션 테스트 등.
    def sign_in_as_admin
      admin = admins(:one)
      post login_url, params: { email: admin.email, password: "password" }
    end
  end
end

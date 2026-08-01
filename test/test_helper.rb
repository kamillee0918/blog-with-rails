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

    # 테스트 환경은 rate_limit 을 검증할 수 있도록 :memory_store 를 쓴다.
    # 그 대가로 캐시가 테스트 간에 살아남으므로 매번 비운다. 특히 로그인
    # rate_limit 은 성공·실패를 가리지 않고 IP 별로 세는데 테스트 요청이 모두
    # 127.0.0.1 이라, 비우지 않으면 setup 에서 로그인하는 테스트들이 서로를
    # 한도 너머로 밀어내 429 를 받는다.
    setup { Rails.cache.clear }

    # Add more helper methods to be used by all tests here...

    # Helper: sign in as admin for controller tests.
    # 사용 예정: uploads_controller_test, 관리자 전용 posts 액션 테스트 등.
    def sign_in_as_admin
      admin = admins(:one)
      post login_url, params: { email: admin.email, password: "password" }
    end
  end
end

require "test_helper"

# ⚠️ 이 프로젝트는 Password 인증을 사용하지 않습니다.
# Magic Link 인증 방식만 지원합니다.
#
# 이 테스트 파일은 향후 Password 기능 추가 시 참고용으로 보관합니다.
# 현재 프로젝트의 인증 관련 테스트는 다음을 참고하세요:
# - test/controllers/sessions_controller_test.rb (Magic Link 인증)
# - test/services/authentication/magic_link_service_test.rb
# - test/services/authentication/otp_service_test.rb

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    skip "Password authentication not implemented - using Magic Link only"
  end

  test "should get edit" do
    # Skipped - would test password edit form
  end

  test "should update password" do
    # Skipped - would test password update
  end

  test "should not update password with wrong password challenge" do
    # Skipped - would test password validation
  end
end

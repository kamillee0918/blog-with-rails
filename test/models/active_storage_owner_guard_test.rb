require "test_helper"

class ActiveStorageOwnerGuardTest < ActiveSupport::TestCase
  # production 에서만 DiskService 에 붙으므로, 테스트는 서비스 인스턴스 하나에만 붙인다.
  # Minitest 6 에는 stub 이 없어 root 판정을 모듈로 덮어쓴다.
  def guarded_service(root:, as_root:)
    service = ActiveStorage::Service::DiskService.new(root: root)
    service.singleton_class.prepend(ActiveStorageOwnerGuard)
    service.singleton_class.prepend(Module.new { define_method(:root_process?) { as_root } })
    service
  end

  def upload(service, key)
    service.upload(key, StringIO.new("x"), checksum: OpenSSL::Digest::MD5.base64digest("x"))
  end

  test "root 로는 업로드하지 못하고 디렉터리도 만들지 않는다" do
    Dir.mktmpdir do |root|
      service = guarded_service(root: root, as_root: true)

      error = assert_raises(ActiveStorageOwnerGuard::RootWriteError) { upload(service, "ab12cdkey") }
      assert_includes error.message, "fly ssh console -u rails"
      assert_empty Dir.children(root)
    end
  end

  test "root 로도 읽기와 삭제는 막지 않는다" do
    Dir.mktmpdir do |root|
      upload(guarded_service(root: root, as_root: false), "ab12cdkey")
      service = guarded_service(root: root, as_root: true)

      assert_equal "x", service.download("ab12cdkey")
      service.delete("ab12cdkey")
      assert_not service.exist?("ab12cdkey")
    end
  end

  test "rails 사용자는 그대로 업로드한다" do
    Dir.mktmpdir do |root|
      service = guarded_service(root: root, as_root: false)

      upload(service, "ab12cdkey")
      assert service.exist?("ab12cdkey")
    end
  end

  test "production 이 아니면 DiskService 에 붙지 않는다" do
    assert_not_includes ActiveStorage::Service::DiskService.ancestors, ActiveStorageOwnerGuard
  end
end

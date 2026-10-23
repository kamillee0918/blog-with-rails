# frozen_string_literal: true

# root 프로세스가 Active Storage 볼륨에 쓰지 못하게 한다.
#
# 앱은 rails(uid 1000)로 돌지만 `fly ssh console` 의 기본 사용자는 root 다. 거기서 runner·console·rake
# 로 표지를 붙이거나 variant 를 구우면 볼륨에 root 소유 755 디렉터리가 생기고, 앱은 그 안에 파일을
# 만들지도 지우지도 못한다. 2026-10-23 에 디렉터리 1012개 중 648개가 root 소유였다:
#
# - PurgeJob 11건이 EACCES 로 실패했다. Blob#purge 는 행을 먼저 지우므로 파일만 고아로 남았다.
# - key 앞 두 글자가 그런 최상위 디렉터리(90개 / 1296)에 걸리는 업로드는 mkdir 에서 실패할 수 있었다.
#
# 쓰기는 모두 DiskService#make_path_for(upload, compose)를 거치므로 거기서 막는다. 읽기와 삭제는
# 소유권을 만들지 않으니 그대로 둔다 — content:check 같은 점검은 root 로 돌아도 볼륨을 바꾸지 않는다.
require "active_storage/service/disk_service"

module ActiveStorageOwnerGuard
  class RootWriteError < StandardError; end

  MESSAGE = "root 로 Active Storage 에 쓰면 rails(uid 1000) 가 그 파일을 지우지 못한다. " \
            "`fly ssh console -u rails` 로 접속해 다시 실행하라."

  private
    def make_path_for(key)
      raise RootWriteError, MESSAGE if root_process?

      super
    end

    def root_process?
      Process.uid.zero?
    end
end

# Windows 의 Process.uid 는 항상 0 이라 개발 환경에서 켜면 모든 업로드가 막힌다.
ActiveStorage::Service::DiskService.prepend(ActiveStorageOwnerGuard) if Rails.env.production?

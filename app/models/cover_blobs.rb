# frozen_string_literal: true

# 이미 올라와 있는 표지 이미지를 다른 글에서 그대로 쓰기 위한 도구.
#
# 같은 그림을 다시 업로드하면 blob 도 variant 도 통째로 한 벌 더 쌓인다. 파일은
# 그대로 두고 attachment 한 줄만 늘리면 저장소도 늘지 않고 이미 만들어 둔 WebP
# variant 도 그대로 재사용된다. `rake cover:reuse` 참고.
#
# 이렇게 blob 을 공유해도 안전한 것은 active_storage_attachments 의 외래 키 덕분이다.
# 참조가 남아 있는 blob 은 purge 해도 ActiveRecord::InvalidForeignKey 에 막혀
# 행도 파일도 지워지지 않는다(ActiveStorage::Blob#purge). 그 전제는 테스트로 못 박아 두었다.
#
# 로직을 rake task 안이 아니라 여기 두는 이유는 테스트를 붙이기 위해서다.
module CoverBlobs
  Error = Class.new(StandardError)

  Result = Struct.new(:status, :source, :target, :blob, keyword_init: true)

  class << self
    # source 글의 표지 blob 을 target 글에 붙인다. 이미 다른 표지가 있으면
    # 실수로 덮어쓰지 않도록 force 를 요구한다.
    def reuse(source:, target:, force: false)
      source_post = find_post(source, "SRC")
      target_post = find_post(target, "DST")

      blob = source_post.cover_image.blob
      raise Error, "원본 글에 표지가 없습니다 — #{source_post.title}" if blob.nil?

      current = target_post.cover_image.blob
      return result(:unchanged, source_post, target_post, blob) if current&.id == blob.id
      return result(:blocked, source_post, target_post, blob) if current && !force

      target_post.cover_image.attach(blob)
      result(:attached, source_post, target_post, blob)
    end

    private
      # 미공개 글도 대상이므로 published 스코프를 태우지 않는다.
      def find_post(param, role)
        Post.find_by_slug_or_id(param) ||
          raise(ActiveRecord::RecordNotFound, "글을 찾지 못했습니다 — #{role}=#{param}")
      end

      def result(status, source_post, target_post, blob)
        Result.new(status: status, source: source_post, target: target_post, blob: blob)
      end
  end
end

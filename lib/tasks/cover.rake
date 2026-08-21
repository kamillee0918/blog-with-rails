# frozen_string_literal: true

namespace :cover do
  desc "다른 글의 표지를 그대로 재사용한다 (SRC=슬러그|id DST=슬러그|id, FORCE=1 이면 기존 표지 교체)"
  task reuse: :environment do
    src = ENV["SRC"].to_s.strip
    dst = ENV["DST"].to_s.strip

    if src.empty? || dst.empty?
      abort("SRC 와 DST 가 필요합니다 — 예: bin/rails cover:reuse SRC=past-part-2 DST=past-part-2-problem-1-walkthrough")
    end

    result = CoverBlobs.reuse(source: src, target: dst, force: ENV["FORCE"].present?)
    blob = result.blob

    case result.status
    when :attached
      puts "붙였습니다 — #{result.target.title}"
    when :unchanged
      puts "이미 같은 표지를 쓰고 있습니다 — #{result.target.title}"
    when :blocked
      abort("이미 다른 표지가 있습니다 (#{result.target.cover_image.blob.filename}). " \
            "바꾸려면 FORCE=1 을 붙이세요 — #{result.target.title}")
    end

    size = ActiveSupport::NumberHelper.number_to_human_size(blob.byte_size)
    puts "  blob ##{blob.id} #{blob.filename} (#{size}) / 분석됨: #{blob.analyzed? ? "예" : "아니오"}"
    puts "  이 blob 을 쓰는 곳: #{ActiveStorage::Attachment.where(blob_id: blob.id).count}건 — 파일은 늘지 않았습니다"
  rescue CoverBlobs::Error, ActiveRecord::RecordNotFound => e
    abort(e.message)
  end
end

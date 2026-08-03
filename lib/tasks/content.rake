# frozen_string_literal: true

namespace :content do
  desc "발행 전 콘텐츠 점검 (본문 링크·alt·요약·태그·표지). SEVERITY=error 로 error 만 볼 수 있다"
  task check: :environment do
    findings = ContentAudit.run
    findings.select! { |f| f.severity == :error } if ENV["SEVERITY"] == "error"

    if findings.empty?
      puts "콘텐츠 점검 통과 — 지적 사항 없음 (글 #{Post.count}건)"
      next
    end

    errors = findings.count { |f| f.severity == :error }
    warnings = findings.size - errors

    findings.group_by(&:check).sort_by { |_, list| -list.size }.each do |check, list|
      severity = list.first.severity == :error ? "오류" : "경고"
      puts "\n[#{severity}] #{check} — #{list.size}건"
      list.sort_by(&:post_id).each do |f|
        puts "  ##{f.post_id} #{f.title.to_s.truncate(38).ljust(38)} #{f.detail}"
      end
    end

    puts "\n합계: 오류 #{errors}건 / 경고 #{warnings}건 (글 #{Post.count}건)"

    # 오류가 있으면 실패로 끝낸다. 경고는 판단 대상이라 종료 코드를 바꾸지 않는다.
    abort("\n오류가 남아 있습니다.") if errors.positive?
  end
end

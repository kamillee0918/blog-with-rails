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

  desc "코드 블록에 덧붙은 이스케이프를 되돌린다 (DRY=1 이면 셈만 한다)"
  task fix_escaping: :environment do
    dry = ENV["DRY"].present?
    result = CodeBlockEscaping.repair(dry_run: dry)

    if result.posts.zero?
      puts "코드 블록 정상 — 되돌릴 것이 없습니다 (글 #{Post.count}건)"
      next
    end

    puts dry ? "DRY — 아무것도 바꾸지 않습니다\n\n" : "\n"
    result.entries.each do |entry|
      puts format("  #%-4d %-38s %3d곳", entry.post.id, entry.post.to_param.truncate(38), entry.count)
      puts "        전: #{entry.before}"
      puts "        후: #{entry.after}"
    end

    puts
    puts format("글 %d건 / %d곳%s", result.posts, result.fixes,
                dry ? " (DRY — 반영하지 않았습니다)" : " 되돌렸습니다")

    # 원인을 고치기 전까지는 글을 저장할 때마다 되살아난다. 여기서 끝났다고
    # 넘어가면 다음 수정 뒤에 조용히 돌아온다.
    puts "글을 다시 저장하면 되살아납니다. 수정 후 이 태스크를 다시 돌리세요." unless dry
  end
end

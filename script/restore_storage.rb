# frozen_string_literal: true

# rev/storage 백업으로부터 Active Storage 디스크 트리를 재구성한다.
#
# 홈서버 → Fly.io 이전용 일회성 도구다. 백업 파일은 파일명에 확장자가 붙어 있고
# 일부는 키가 달라도 내용이 같아서(같은 썸네일을 여러 글에 재사용), 단순 복사로는
# 복원되지 않는다. 그래서 두 단계로 찾는다.
#
#   1) 키 일치      — 백업 경로가 그대로 맞는 경우
#   2) 체크섬 일치  — 키는 다르지만 내용이 동일한 파일이 백업에 있는 경우
#
# 결과는 OUT_DIR 에 Active Storage 규약(확장자 없는 key, xx/yy/key)대로 쌓인다.
# 이 디렉터리를 통째로 Fly 볼륨의 /rails/storage 에 올리면 된다.
#
# 사용법:
#   ruby script/restore_storage.rb            # 복원 실행
#   ruby script/restore_storage.rb --dry-run  # 계획만 출력

require "pg"
require "uri"
require "digest"
require "base64"
require "fileutils"

BACKUP  = ENV.fetch("BACKUP_DIR", "rev/storage")
OUT_DIR = ENV.fetch("OUT_DIR", "tmp/storage_restored")
DRY_RUN = ARGV.include?("--dry-run")

def load_env(path = ".env")
  {}.tap do |env|
    File.readlines(path).each do |line|
      next if line.strip.empty? || line.strip.start_with?("#")
      k, v = line.chomp.split("=", 2)
      env[k] = v.to_s.strip if k
    end
  end
end

def md5(path) = Base64.strict_encode64(Digest::MD5.digest(File.binread(path)))

env = load_env
url = env.fetch("SUPABASE_DB_URL") { abort "ERROR: .env 에 SUPABASE_DB_URL 이 없습니다." }
u = URI.parse(url)
conn = PG.connect(
  host: u.host, port: u.port, dbname: (u.path || "/postgres").delete_prefix("/"),
  user: URI.decode_www_form_component(u.user.to_s),
  password: URI.decode_www_form_component(u.password.to_s),
  sslmode: "require", connect_timeout: 15
)
conn.exec("SET default_transaction_read_only = on")

# 백업 색인: 확장자 제거한 키 → 경로 / 체크섬 → 경로
by_key = {}
by_sum = {}
Dir.glob(File.join(BACKUP, "*", "*", "*")).each do |f|
  next if File.directory?(f)
  by_key[File.basename(f).sub(/\.[A-Za-z0-9]+\z/, "")] = f
  by_sum[md5(f)] ||= f
end
puts "백업 색인: 파일 #{by_key.size}개 / 고유 체크섬 #{by_sum.size}개"

blobs = conn.exec(<<~SQL).to_a
  select b.id, b.key, b.filename, b.checksum, b.byte_size,
         coalesce(a.record_type, '(unattached)') as rec, a.record_id
  from active_storage_blobs b
  left join active_storage_attachments a on a.blob_id = b.id
  order by b.id
SQL

stats = { by_key: 0, by_sum: 0, missing: [] }

blobs.each do |b|
  key = b["key"]
  src =
    if (f = by_key[key]) && md5(f) == b["checksum"] then (stats[:by_key] += 1; f)
    elsif (f = by_sum[b["checksum"]])               then (stats[:by_sum] += 1; f)
    end

  unless src
    stats[:missing] << b
    next
  end

  dest = File.join(OUT_DIR, key[0, 2], key[2, 2], key)
  next if DRY_RUN
  FileUtils.mkdir_p(File.dirname(dest))
  FileUtils.cp(src, dest)
end

puts "\n=== 복원 결과#{DRY_RUN ? ' (dry-run — 파일을 쓰지 않음)' : ''} ==="
puts "  키 일치로 복원:       #{stats[:by_key]}"
puts "  체크섬 일치로 복원:   #{stats[:by_sum]}"
puts "  복원 불가:            #{stats[:missing].size}"
puts "  출력 위치:            #{OUT_DIR}" unless DRY_RUN

variants, originals = stats[:missing].partition { |b| b["rec"] == "ActiveStorage::VariantRecord" }
puts <<~WARN unless variants.empty?

  ⚠️  variant #{variants.size}건은 파일이 없다. 그런데 DB 에 VariantRecord 행이 남아 있으면
      Rails 는 "이미 생성됨"으로 보고 재생성하지 않고 그 파일을 스트리밍하려다 404 를 낸다.
      따라서 파일 없는 VariantRecord 를 먼저 지워야 재생성이 일어난다:

        fly ssh console -C "bin/rails runner 'ActiveStorage::VariantRecord.includes(image_attachment: :blob).find_each { |v| b = v.image_blob; next if b && ActiveStorage::Blob.service.exist?(b.key); v.image_attachment&.purge; v.destroy }'"
WARN

return if originals.empty?

puts "\n=== 재업로드가 필요한 원본 (고유 파일 기준) ==="
originals.group_by { |b| b["checksum"] }.sort_by { |_, v| -v.size }.each do |_, group|
  first = group.first
  posts = group.select { |b| b["rec"] == "Post" }.map { |b| b["record_id"] }
  label = posts.empty? ? "본문 임베드용" : "표지: post #{posts.join(', ')}"
  puts format("  %-32s %6dKB  blob %d건  [%s]",
              first["filename"], first["byte_size"].to_i / 1024, group.size, label)
end

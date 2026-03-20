# === SQLite → PostgreSQL (Supabase) 데이터 마이그레이션 ===
#
# 사용법:
#   SQLITE_PATH=production_backup_re.sqlite3 bin/rails import:all
#
# 또는 Docker 컨테이너 내부에서:
#   SQLITE_PATH=/rails/production_backup_re.sqlite3 bin/rails import:all
#
# 순서: blobs → attachments → variant_records → posts → rich_texts → tags + posts_tags
# ID를 보존하여 ActionText body 내부의 sgid 참조가 유지됩니다.
#
namespace :import do
  desc "SQLite 백업에서 모든 데이터를 PostgreSQL로 이전"
  task all: :environment do
    require "sqlite3"

    sqlite_path = ENV.fetch("SQLITE_PATH") do
      abort "ERROR: SQLITE_PATH 환경변수를 설정하세요. 예: SQLITE_PATH=production_backup_re.sqlite3 bin/rails import:all"
    end

    unless File.exist?(sqlite_path)
      abort "ERROR: 파일을 찾을 수 없습니다: #{sqlite_path}"
    end

    db = SQLite3::Database.new(sqlite_path)
    db.results_as_hash = true
    conn = ActiveRecord::Base.connection

    puts "=== SQLite → PostgreSQL 데이터 마이그레이션 시작 ==="
    puts "소스: #{sqlite_path}"
    puts

    # --- 1. Active Storage Blobs ---
    blobs = db.execute("SELECT * FROM active_storage_blobs ORDER BY id")
    puts "[1/6] active_storage_blobs: #{blobs.size}개"
    blobs.each do |row|
      conn.execute(<<~SQL)
        INSERT INTO active_storage_blobs (id, key, filename, content_type, metadata, service_name, byte_size, checksum, created_at)
        VALUES (
          #{row['id']},
          #{conn.quote(row['key'])},
          #{conn.quote(row['filename'])},
          #{conn.quote(row['content_type'])},
          #{conn.quote(row['metadata'])},
          #{conn.quote(row['service_name'])},
          #{row['byte_size']},
          #{conn.quote(row['checksum'])},
          #{conn.quote(row['created_at'])}
        )
        ON CONFLICT (id) DO NOTHING
      SQL
    end
    reset_sequence(conn, "active_storage_blobs")

    # --- 2. Active Storage Attachments ---
    attachments = db.execute("SELECT * FROM active_storage_attachments ORDER BY id")
    puts "[2/6] active_storage_attachments: #{attachments.size}개"
    attachments.each do |row|
      conn.execute(<<~SQL)
        INSERT INTO active_storage_attachments (id, name, record_type, record_id, blob_id, created_at)
        VALUES (
          #{row['id']},
          #{conn.quote(row['name'])},
          #{conn.quote(row['record_type'])},
          #{row['record_id']},
          #{row['blob_id']},
          #{conn.quote(row['created_at'])}
        )
        ON CONFLICT (id) DO NOTHING
      SQL
    end
    reset_sequence(conn, "active_storage_attachments")

    # --- 3. Active Storage Variant Records ---
    variants = db.execute("SELECT * FROM active_storage_variant_records ORDER BY id")
    puts "[3/6] active_storage_variant_records: #{variants.size}개"
    variants.each do |row|
      conn.execute(<<~SQL)
        INSERT INTO active_storage_variant_records (id, blob_id, variation_digest)
        VALUES (
          #{row['id']},
          #{row['blob_id']},
          #{conn.quote(row['variation_digest'])}
        )
        ON CONFLICT (id) DO NOTHING
      SQL
    end
    reset_sequence(conn, "active_storage_variant_records")

    # --- 4. Posts (tags 문자열 컬럼 제외) ---
    posts = db.execute("SELECT * FROM posts ORDER BY id")
    puts "[4/6] posts: #{posts.size}개"
    posts.each do |row|
      conn.execute(<<~SQL)
        INSERT INTO posts (id, title, summary, author, slug, category, published_at, created_at, updated_at)
        VALUES (
          #{row['id']},
          #{conn.quote(row['title'])},
          #{conn.quote(row['summary'])},
          #{conn.quote(row['author'])},
          #{conn.quote(row['slug'])},
          #{conn.quote(row['category'])},
          #{conn.quote(row['published_at'])},
          #{conn.quote(row['created_at'])},
          #{conn.quote(row['updated_at'])}
        )
        ON CONFLICT (id) DO NOTHING
      SQL
    end
    reset_sequence(conn, "posts")

    # --- 5. Action Text Rich Texts ---
    rich_texts = db.execute("SELECT * FROM action_text_rich_texts ORDER BY id")
    puts "[5/6] action_text_rich_texts: #{rich_texts.size}개"
    rich_texts.each do |row|
      conn.execute(<<~SQL)
        INSERT INTO action_text_rich_texts (id, name, body, record_type, record_id, created_at, updated_at)
        VALUES (
          #{row['id']},
          #{conn.quote(row['name'])},
          #{conn.quote(row['body'])},
          #{conn.quote(row['record_type'])},
          #{row['record_id']},
          #{conn.quote(row['created_at'])},
          #{conn.quote(row['updated_at'])}
        )
        ON CONFLICT (id) DO NOTHING
      SQL
    end
    reset_sequence(conn, "action_text_rich_texts")

    # --- 6. Tags (문자열 파싱 → tags + posts_tags) ---
    puts "[6/6] tags 정규화 (posts.tags 문자열 → tags + posts_tags)"
    tag_count = 0
    assoc_count = 0

    posts.each do |row|
      tags_str = row["tags"]
      next if tags_str.nil? || tags_str.strip.empty?

      tag_names = tags_str.split(",").map(&:strip).reject(&:empty?).map(&:downcase).uniq
      tag_names.each do |name|
        # Tag upsert
        conn.execute(<<~SQL)
          INSERT INTO tags (name, created_at, updated_at)
          VALUES (#{conn.quote(name)}, #{conn.quote(row['created_at'])}, #{conn.quote(row['updated_at'])})
          ON CONFLICT (name) DO NOTHING
        SQL

        tag_id = conn.select_value("SELECT id FROM tags WHERE name = #{conn.quote(name)}")
        tag_count += 1 if tag_id

        # posts_tags association
        conn.execute(<<~SQL)
          INSERT INTO posts_tags (post_id, tag_id)
          VALUES (#{row['id']}, #{tag_id})
          ON CONFLICT (post_id, tag_id) DO NOTHING
        SQL
        assoc_count += 1
      end
    end
    reset_sequence(conn, "tags")

    # --- 결과 요약 ---
    puts
    puts "=== 마이그레이션 완료 ==="
    puts "  posts:                        #{conn.select_value('SELECT COUNT(*) FROM posts')}"
    puts "  action_text_rich_texts:        #{conn.select_value('SELECT COUNT(*) FROM action_text_rich_texts')}"
    puts "  active_storage_blobs:          #{conn.select_value('SELECT COUNT(*) FROM active_storage_blobs')}"
    puts "  active_storage_attachments:    #{conn.select_value('SELECT COUNT(*) FROM active_storage_attachments')}"
    puts "  active_storage_variant_records:#{conn.select_value('SELECT COUNT(*) FROM active_storage_variant_records')}"
    puts "  tags:                          #{conn.select_value('SELECT COUNT(*) FROM tags')}"
    puts "  posts_tags:                    #{conn.select_value('SELECT COUNT(*) FROM posts_tags')}"
  end

  desc "마이그레이션 결과 검증"
  task verify: :environment do
    conn = ActiveRecord::Base.connection
    puts "=== 데이터 검증 ==="

    posts = Post.order(:id)
    puts "총 게시글: #{posts.count}"
    puts

    posts.each do |post|
      content_ok = post.content.present? ? "✓" : "✗"
      tags_str = post.tags.pluck(:name).join(", ")
      tags_ok = tags_str.present? ? tags_str : "(없음)"
      puts "  ##{post.id} #{post.title} | 본문:#{content_ok} | 태그:#{tags_ok}"
    end

    puts
    puts "Active Storage blobs: #{ActiveStorage::Blob.count}"
    puts "Active Storage attachments: #{ActiveStorage::Attachment.count}"
    puts "Tags: #{Tag.count}"
  end

  private

  def reset_sequence(conn, table_name)
    max_id = conn.select_value("SELECT COALESCE(MAX(id), 0) FROM #{table_name}")
    conn.execute("SELECT setval(pg_get_serial_sequence('#{table_name}', 'id'), #{max_id + 1}, false)")
  rescue => e
    puts "  (sequence 리셋 건너뜀: #{table_name} — #{e.message})"
  end
end

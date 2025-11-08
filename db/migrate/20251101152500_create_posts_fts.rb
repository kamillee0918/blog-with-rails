# frozen_string_literal: true

class CreatePostsFts < ActiveRecord::Migration[8.0]
  def up
    # SQLite FTS5 virtual table 생성
    execute <<-SQL
      CREATE VIRTUAL TABLE IF NOT EXISTS posts_fts USING fts5(
        title,
        content,
        excerpt,
        category,
        author_name,
        content='posts',
        content_rowid='id'
      );
    SQL

    # 기존 posts 데이터를 FTS 테이블에 삽입
    execute <<-SQL
      INSERT INTO posts_fts(rowid, title, content, excerpt, category, author_name)
      SELECT id, title, content, excerpt, category, author_name FROM posts;
    SQL

    # posts 테이블에 트리거 추가 (자동 FTS 업데이트)
    execute <<-SQL
      CREATE TRIGGER posts_fts_insert AFTER INSERT ON posts BEGIN
        INSERT INTO posts_fts(rowid, title, content, excerpt, category, author_name)
        VALUES (new.id, new.title, new.content, new.excerpt, new.category, new.author_name);
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER posts_fts_update AFTER UPDATE ON posts BEGIN
        UPDATE posts_fts SET
          title = new.title,
          content = new.content,
          excerpt = new.excerpt,
          category = new.category,
          author_name = new.author_name
        WHERE rowid = new.id;
      END;
    SQL

    execute <<-SQL
      CREATE TRIGGER posts_fts_delete AFTER DELETE ON posts BEGIN
        DELETE FROM posts_fts WHERE rowid = old.id;
      END;
    SQL
  end

  def down
    execute "DROP TRIGGER IF EXISTS posts_fts_delete;"
    execute "DROP TRIGGER IF EXISTS posts_fts_update;"
    execute "DROP TRIGGER IF EXISTS posts_fts_insert;"
    execute "DROP TABLE IF EXISTS posts_fts;"
  end
end

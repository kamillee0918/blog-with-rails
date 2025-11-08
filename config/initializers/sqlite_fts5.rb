# frozen_string_literal: true

# SQLite FTS5 virtual table의 내부 시스템 테이블을 schema dump에서 제외
# FTS5는 자동으로 4개의 내부 테이블을 생성하며, 이들은 명시적으로 생성할 수 없음
# sqlite_sequence도 SQLite가 자동 관리하는 내부 테이블이므로 제외
ActiveRecord::SchemaDumper.ignore_tables += [
  /.*_fts_data$/,      # FTS5 data storage
  /.*_fts_idx$/,       # FTS5 index
  /.*_fts_docsize$/,   # FTS5 document size
  /.*_fts_config$/,    # FTS5 configuration
  "sqlite_sequence"    # SQLite auto-increment sequence
]

class AddPublishedAtIndexToPosts < ActiveRecord::Migration[8.1]
  # published 스코프 필터, recent 정렬, 연도별 아카이브, 이전/다음 글 조회가
  # 모두 published_at을 기준으로 동작하지만 인덱스가 없어 전 테이블 스캔이었다.
  def change
    add_index :posts, :published_at
  end
end

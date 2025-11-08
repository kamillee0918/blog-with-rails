# frozen_string_literal: true

class AddIndexesAndUserRelationToPosts < ActiveRecord::Migration[8.0]
  def change
    # author_name에 인덱스 추가 (카테고리별 작가 필터링 성능 향상)
    add_index :posts, :author_name unless index_exists?(:posts, :author_name)

    # User와 Post 관계 설정 (optional: 기존 author_name도 유지)
    add_reference :posts, :user, foreign_key: true, index: true
  end
end

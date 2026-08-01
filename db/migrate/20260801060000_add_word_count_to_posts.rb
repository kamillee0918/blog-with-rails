class AddWordCountToPosts < ActiveRecord::Migration[8.1]
  # read_time 은 목록 카드마다 호출되는데, 매번 Action Text 본문 전체를 읽어와
  # Nokogiri 로 파싱했다. "N min read" 한 줄을 위해 10건짜리 페이지가 본문
  # 수백 KB 를 DB 에서 끌어오는 구조라 단어 수만 미리 저장해 둔다.
  def up
    add_column :posts, :word_count, :integer

    Post.reset_column_information
    Post.includes(:rich_text_content).find_each do |post|
      post.update_column(:word_count, post.content.to_plain_text.to_s.split.size)
    end
  end

  def down
    remove_column :posts, :word_count
  end
end

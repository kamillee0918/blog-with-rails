class Tag < ApplicationRecord
  has_and_belongs_to_many :posts

  validates :name, presence: true, uniqueness: true

  # 태그 이름을 소문자로 정규화
  before_validation :normalize_name

  scope :popular, -> { left_joins(:posts).group(:id).order(Arel.sql("COUNT(posts.id) DESC")) }

  # 인기 태그 목록 (이름 + 게시글 수) 반환
  def self.popular_with_counts(limit = 10)
    joins(:posts)
      .group("tags.id", "tags.name")
      .order(Arel.sql("COUNT(posts.id) DESC"))
      .limit(limit)
      .pluck(Arel.sql("tags.name"), Arel.sql("COUNT(posts.id)"))
  end

  def self.find_or_create_by_name(name)
    find_or_create_by(name: name.strip.downcase)
  end

  private

  def normalize_name
    self.name = name.strip.downcase if name.present?
  end
end

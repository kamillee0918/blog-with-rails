class Post < ApplicationRecord
  has_rich_text :content
  has_one_attached :cover_image do |attachable|
    # 미리 생성할 variant 정의 (on-demand로 생성됨)
    attachable.variant :thumbnail, resize_to_limit: [ 160, 160 ], format: :webp, saver: { quality: 80 }
    attachable.variant :small, resize_to_limit: [ 380, 250 ], format: :webp, saver: { quality: 80 }
    attachable.variant :medium, resize_to_limit: [ 640, 430 ], format: :webp, saver: { quality: 80 }
    attachable.variant :large, resize_to_limit: [ 1024, 688 ], format: :webp, saver: { quality: 80 }
    attachable.variant :hero, resize_to_limit: [ 1920, 1080 ], format: :webp, saver: { quality: 85 }
  end

  # === Validations ===
  validates :title, presence: true
  validates :published_at, presence: true
  validates :category, presence: true
  validates :slug, uniqueness: true, allow_blank: true  # slug는 선택사항 (한국어 제목 대응)

  # === Callbacks ===
  before_validation :generate_slug

  # === Scopes ===
  scope :published, -> { where("published_at <= ?", Time.current) }
  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(published_at: :desc) }
  scope :by_year, ->(year) { where("strftime('%Y', published_at) = ?", year.to_s) }
  scope :search, ->(query) {
    return none if query.blank?
    where("title LIKE :q OR summary LIKE :q OR tags LIKE :q", q: "%#{query}%")
  }
  scope :by_tag, ->(tag) {
    return none if tag.blank?
    where("tags LIKE ?", "%#{tag}%")
  }

  # === URL에 사용할 파라미터 ===
  # slug가 있으면 slug, 없으면 id 사용
  def to_param
    slug.presence || id.to_s
  end

  # === ID 또는 slug로 레코드 찾기 ===
  def self.find_by_slug_or_id(param)
    # 숫자로만 구성되면 id로 찾기, 아니면 slug로 찾기
    if param.to_s.match?(/\A\d+\z/)
      find_by(id: param) || find_by(slug: param)
    else
      find_by(slug: param) || find_by(id: param)
    end
  end

  def self.find_by_slug_or_id!(param)
    find_by_slug_or_id(param) || raise(ActiveRecord::RecordNotFound, "Couldn't find Post")
  end

  # 연도별 게시글 수 (archive 사이드바용)
  def self.yearly_archive_counts
    group("strftime('%Y', published_at)").count
  end

  # === Instance Methods ===

  # 이전 게시글 (published_at 기준)
  def previous_post
    Post.where("published_at < ?", published_at).recent.first
  end

  # 다음 게시글 (published_at 기준)
  def next_post
    Post.where("published_at > ?", published_at).order(published_at: :asc).first
  end

  # 추천 게시글: 같은 태그를 가진 게시글
  def recommended_posts(limit: 3)
    return [] if tags.blank?

    my_tags = tags.split(",").map(&:strip)
    Post.where.not(id: id)
        .where("tags IS NOT NULL AND tags != ''")
        .select { |p| (p.tags.split(",").map(&:strip) & my_tags).any? }
        .first(limit)
  end

  def read_time
    words_per_minute = 180
    text_content = content.to_plain_text
    word_count = text_content.split.size
    minutes = (word_count / words_per_minute).ceil
    "#{minutes} min read"
  end

  # 커버 이미지 캡션 반환
  def cover_image_caption
    return nil unless cover_image.attached?

    cover_image.blob.metadata["caption"]
  end

  private

  # 영어 제목은 자동 slug 생성, 한국어 제목은 slug 비워둠 (ID로 접근)
  def generate_slug
    return if slug.present?  # 이미 slug가 있으면 유지
    return unless title.present?

    generated = title.parameterize
    # parameterize 결과가 있을 때만 slug 설정 (영어 제목)
    # 한국어 제목은 빈 문자열이 되므로 slug를 nil로 유지
    self.slug = generated.presence
  end
end

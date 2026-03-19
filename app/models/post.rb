class Post < ApplicationRecord
  has_and_belongs_to_many :tags
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
  scope :by_year, ->(year) {
    start_date = Date.new(year.to_i, 1, 1).beginning_of_day
    end_date = Date.new(year.to_i, 12, 31).end_of_day
    where(published_at: start_date..end_date)
  }
  scope :search, ->(query) {
    return none if query.blank?
    sanitized = "%#{sanitize_sql_like(query)}%"
    left_joins(:tags)
      .where("LOWER(posts.title) LIKE LOWER(:q) OR LOWER(posts.summary) LIKE LOWER(:q) OR LOWER(tags.name) LIKE LOWER(:q)", q: sanitized)
      .distinct
  }
  scope :by_tag, ->(tag) {
    return none if tag.blank?
    joins(:tags).where("LOWER(tags.name) = LOWER(?)", tag.strip).distinct
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
    pluck(:published_at).compact.group_by { |date| date.year.to_s }.transform_values(&:count)
  end

  # === Instance Methods ===

  # 이전 게시글 (published_at 기준)
  def previous_post
    Post.published.where("published_at < ?", published_at).recent.first
  end

  # 다음 게시글 (published_at 기준)
  def next_post
    Post.published.where("published_at > ?", published_at).order(published_at: :asc).first
  end

  # 추천 게시글: 같은 태그를 가진 게시글
  def recommended_posts(limit: 3)
    my_tag_ids = tags.pluck(:id)
    return [] if my_tag_ids.empty?

    Post.joins("INNER JOIN posts_tags ON posts_tags.post_id = posts.id")
        .where("posts_tags.tag_id IN (?)", my_tag_ids)
        .where.not(id: id)
        .distinct
        .limit(limit)
  end

  # 폼 호환용: 쉼표 구분 문자열 ↔ Tag associations
  def tag_list
    tags.pluck(:name).join(", ")
  end

  def tag_list=(names)
    self.tags = names.split(",").map(&:strip).reject(&:blank?).uniq.map do |name|
      Tag.find_or_create_by_name(name)
    end
  end

  def read_time
    words_per_minute = 180
    text_content = content.to_plain_text
    word_count = text_content.split.size
    minutes = [ 1, (word_count / words_per_minute.to_f).ceil ].max
    "#{minutes} min read"
  end

  # 코드 블록 내용을 복원하여 표시용 콘텐츠 반환
  # Base64 인코딩된 코드 블록 → 원래 HTML 엔티티로 디코딩
  # 기존 ⟦ERB_*⟧ placeholder 게시글도 폴백으로 지원 (하위 호환)
  def rendered_content
    return content if content.body.blank?

    html = content.body.to_s

    # Base64 인코딩된 코드 블록 디코딩
    html = html.gsub(%r{(<pre[^>]*>\s*<code[^>]*>)\s*BASE64:([\w+/=]+)\s*(</code>\s*</pre>)}mi) do
      open_tags = $1
      encoded = $2
      close_tags = $3
      decoded = Base64.strict_decode64(encoded).force_encoding("UTF-8")
      "#{open_tags}#{decoded}#{close_tags}"
    end

    # 기존 ⟦ERB_*⟧ placeholder 폴백 (하위 호환)
    html = html.gsub("⟦ERB_EQ⟧", "&lt;%=")
    html = html.gsub("⟦ERB_HASH⟧", "&lt;%#")
    html = html.gsub("⟦ERB_OPEN⟧", "&lt;%")
    html = html.gsub("⟦ERB_CLOSE⟧", "%&gt;")

    html.html_safe
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

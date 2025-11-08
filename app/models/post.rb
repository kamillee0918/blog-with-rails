class Post < ApplicationRecord
  # Associations
  belongs_to :user, optional: true

  # Validations
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9\-]+\z/, message: "only allows lowercase letters, numbers, and hyphens" }
  validates :content, presence: true
  validates :category, presence: true

  # Callbacks
  after_create :notify_newsletter_subscribers, if: :should_notify_subscribers?

  # Scopes
  scope :published, -> { where.not(published_at: nil).where("published_at <= ?", Time.current) }
  scope :featured, -> { where(featured: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_author_slug, ->(author_slug) { where("LOWER(author_name) LIKE ?", "#{author_slug.downcase}%") }
  scope :recent, -> { order(published_at: :desc) }
  scope :search, ->(query) {
    return all if query.blank?

    begin
      # SQLite FTS5 사용 (훨씬 빠른 검색)
      sanitized_query = sanitize_sql_like(query.to_s)

      # FTS5 테이블에서 검색 후 posts 테이블과 조인
      # 주의: select를 사용하면 count 시 문제가 발생하므로, 필요한 경우에만 select 추가
      joins("INNER JOIN posts_fts ON posts.id = posts_fts.rowid")
        .where("posts_fts MATCH ?", sanitized_query)
        .order("posts_fts.rank")
    rescue ActiveRecord::StatementInvalid => e
      # FTS5 테이블이 없는 경우 fallback (개발 초기 또는 마이그레이션 전)
      Rails.logger.warn "FTS5 search failed, falling back to LIKE: #{e.message}"
      sanitized_query = "%#{sanitize_sql_like(query.to_s)}%"
      where(
        "LOWER(title) LIKE ? OR LOWER(content) LIKE ? OR LOWER(category) LIKE ? OR LOWER(excerpt) LIKE ?",
        sanitized_query.downcase, sanitized_query.downcase, sanitized_query.downcase, sanitized_query.downcase
      )
    end
  }

  # Instance methods
  def published?
    published_at.present? && published_at <= Time.current
  end

  def reading_time
    return 1 if content.blank?

    # Estimate reading time based on word count (average 200 words per minute)
    word_count = content.split.size
    (word_count / 200.0).ceil
  end

  def to_param
    slug
  end

  def path
    "/#{slug}"
  end

  def author_slug
    author_name&.split&.first&.downcase
  end

  # User와 연결된 경우 User 정보를 우선 사용, 아니면 author_name 사용
  def author_display_name
    user&.nickname || author_name
  end

  def author_display_avatar
    user&.email&.then { |email| "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}" } || author_avatar
  end

  private

  # Kamil Lee가 작성한 포스트만 알림 발송
  def should_notify_subscribers?
    author_name == "Kamil Lee" && published?
  end

  # Newsletter 구독자에게 알림 발송
  def notify_newsletter_subscribers
    User.newsletter_subscribers.find_each do |user|
      UserMailer.new_post_notification(user, self).deliver_later
    end
  end
end

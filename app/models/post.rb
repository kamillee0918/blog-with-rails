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
  after_save :clear_categories_cache, if: :saved_change_to_category?
  after_destroy :clear_categories_cache

  # Scopes
  scope :published, -> { where.not(published_at: nil).where("published_at <= ?", Time.current) }
  scope :featured, -> { where(featured: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_author_slug, ->(author_slug) { where("LOWER(author_name) LIKE ?", "#{author_slug.downcase}%") }
  scope :recent, -> { order(published_at: :desc) }
  scope :search, ->(query) {
    return all if query.blank?

    # Simple LIKE search (works with SQLite and PostgreSQL)
    sanitized_query = "%#{sanitize_sql_like(query.to_s)}%"
    where(
      "LOWER(title) LIKE ? OR LOWER(content) LIKE ? OR LOWER(category) LIKE ? OR LOWER(excerpt) LIKE ?",
      sanitized_query.downcase, sanitized_query.downcase, sanitized_query.downcase, sanitized_query.downcase
    )
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

  # 카테고리 목록 캐시 무효화
  def clear_categories_cache
    Rails.cache.delete("categories_list")
  end
end

class Post < ApplicationRecord
  # Validations
  validates :title, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9\-]+\z/, message: "only allows lowercase letters, numbers, and hyphens" }
  validates :content, presence: true
  validates :category, presence: true

  # Scopes
  scope :published, -> { where.not(published_at: nil).where("published_at <= ?", Time.current) }
  scope :featured, -> { where(featured: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_author_slug, ->(author_slug) { where("LOWER(author_name) LIKE ?", "#{author_slug.downcase}%") }
  scope :recent, -> { order(published_at: :desc) }
  scope :search, ->(query) {
    return all if query.blank?

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
end

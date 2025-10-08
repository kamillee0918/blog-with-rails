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
  scope :recent, -> { order(published_at: :desc) }

  # Instance methods
  def published?
    published_at.present? && published_at <= Time.current
  end

  def to_param
    slug
  end
end

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

  validates :title, presence: true
  validates :published_at, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :category, presence: true

  before_validation :generate_slug

  scope :published, -> { where("published_at <= ?", Time.current) }
  scope :featured, -> { where(featured: true) } # If we had a featured column, but we don't yet. I'll stick to what exists.
  scope :by_category, ->(category) { where(category: category) }
  scope :recent, -> { order(published_at: :desc) }

  def to_param
    slug
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

  def generate_slug
    if title.present? && slug.blank?
      generated = title.parameterize
      self.slug = generated.presence || "post-#{SecureRandom.hex(4)}"
    end
  end
end

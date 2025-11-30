# frozen_string_literal: true

module ImageHelper
  # 이미지 사이즈 프리셋 정의
  IMAGE_SIZES = {
    thumbnail: { width: 160, height: 160 },
    small: { width: 380, height: 250 },
    medium: { width: 640, height: 430 },
    large: { width: 1024, height: 688 },
    hero: { width: 1920, height: 1080 }
  }.freeze

  # 최적화된 이미지 태그 생성
  # @param attachment [ActiveStorage::Attached] ActiveStorage 첨부 이미지
  # @param size [Symbol] 이미지 사이즈 프리셋 (:thumbnail, :small, :medium, :large, :hero)
  # @param options [Hash] 추가 옵션 (lazy, alt, class 등)
  def optimized_image_tag(attachment, size: :medium, lazy: true, **options)
    return nil unless attachment.attached?

    dimensions = IMAGE_SIZES[size] || IMAGE_SIZES[:medium]

    # WebP 변환 및 리사이즈 variant 생성
    variant = attachment.variant(
      resize_to_limit: [ dimensions[:width], dimensions[:height] ],
      format: :webp,
      saver: { quality: 80 }
    )

    # 기본 옵션 설정
    default_options = {
      alt: options.delete(:alt) || "",
      class: options.delete(:class) || "",
      decoding: "async"
    }

    # Lazy loading 설정 (Hero 이미지는 제외)
    if lazy
      default_options[:loading] = "lazy"
    else
      default_options[:fetchpriority] = "high"
    end

    image_tag(variant, **default_options.merge(options))
  end

  # srcset을 포함한 반응형 이미지 태그 생성
  # @param source [ActiveStorage::Attached, String] ActiveStorage 첨부 이미지 또는 static 이미지 경로
  # @param sizes_attr [String] sizes 속성 값
  # @param options [Hash] 추가 옵션
  def responsive_image_tag(source, sizes_attr: "(max-width: 1024px) 100vw, 1024px", lazy: true, fetchpriority: true, **options)
    return nil if source.blank?

    default_options = {
      alt: options.delete(:alt) || "",
      class: options.delete(:class) || "",
      decoding: "async",
      sizes: sizes_attr
    }

    if lazy
      default_options[:loading] = "lazy"
    end

    if fetchpriority
      default_options[:fetchpriority] = "high"
    end

    if source.is_a?(ActiveStorage::Attached)
      return nil unless source.attached?

      srcset_sizes = [ 380, 640, 800, 1024, 1280, 1920 ]

      srcset = srcset_sizes.map do |width|
        variant = source.variant(
          resize_to_limit: [ width, nil ],
          format: :webp,
          saver: { quality: 80 }
        )
        "#{url_for(variant)} #{width}w"
      end.join(", ")

      default_variant = source.variant(
        resize_to_limit: [ 1024, nil ],
        format: :webp,
        saver: { quality: 80 }
      )

      default_options[:srcset] = srcset
      image_tag(default_variant, **default_options.merge(options))

    elsif source.is_a?(String) && source.start_with?("thumbnail/")
      # Static images in app/assets/images/thumbnail/
      filename = source.sub("thumbnail/", "")

      # Reference sizes + existing project sizes
      srcset_sizes = [ 380, 640, 768, 800, 1024, 1160, 1280, 1536, 1920, 2048 ]

      srcset = srcset_sizes.map do |width|
        "#{thumbnail_path(filename: filename, width: width)} #{width}w"
      end.join(", ")

      # Add original/large size as well if needed, or just rely on the srcset
      # Default src can be the 1024w version or the original
      default_src = thumbnail_path(filename: filename, width: 1024)

      default_options[:srcset] = srcset
      image_tag(default_src, **default_options.merge(options))
    else
      # Fallback for other static images
      image_tag(source, **default_options.merge(options))
    end
  end

  # <picture> 태그로 WebP와 폴백 이미지 제공
  # @param attachment [ActiveStorage::Attached] ActiveStorage 첨부 이미지
  # @param size [Symbol] 이미지 사이즈 프리셋
  # @param options [Hash] 추가 옵션
  def picture_tag(attachment, size: :medium, lazy: true, **options)
    return nil unless attachment.attached?

    dimensions = IMAGE_SIZES[size] || IMAGE_SIZES[:medium]

    # WebP variant
    webp_variant = attachment.variant(
      resize_to_limit: [ dimensions[:width], dimensions[:height] ],
      format: :webp,
      saver: { quality: 80 }
    )

    # 원본 포맷 variant (폴백용)
    fallback_variant = attachment.variant(
      resize_to_limit: [ dimensions[:width], dimensions[:height] ]
    )

    loading_attr = lazy ? 'loading="lazy"' : 'fetchpriority="high"'
    alt_text = options[:alt] || ""
    css_class = options[:class] || ""

    content_tag(:picture) do
      concat tag(:source, type: "image/webp", srcset: url_for(webp_variant))
      concat image_tag(fallback_variant, alt: alt_text, class: css_class, decoding: "async", **options.except(:alt, :class))
    end
  end
end

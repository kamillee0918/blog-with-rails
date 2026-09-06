# frozen_string_literal: true

module ImageHelper
  # 크기 표와 variant 이름은 Post 가 named variant 로 선언한 것을 그대로 쓴다.
  #
  # 여기서 인라인 해시로 variant 를 만들면 Post 가 미리 구워 둔 것과 키가 어긋나,
  # preprocessed 를 붙여 놓고도 방문자 요청 안에서 libvips 가 다시 돈다. 실제로
  # 예전에는 그 상태였다 — 프리셋 이름은 선언만 되어 있고 뷰는 해시를 넘겼다.

  # 최적화된 이미지 태그 생성
  # @param attachment [ActiveStorage::Attached] ActiveStorage 첨부 이미지
  # @param size [Symbol] 이미지 사이즈 프리셋 (:thumbnail, :small, :medium, :large, :hero)
  # @param options [Hash] 추가 옵션 (lazy, alt, class 등)
  def optimized_image_tag(attachment, size: :medium, lazy: true, **options)
    return nil unless attachment.attached?

    name = Post::COVER_SIZES.key?(size) ? size : :medium
    width, height = Post::COVER_SIZES.fetch(name)

    variant = attachment.variant(name)

    # 기본 옵션 설정
    default_options = {
      alt: options.delete(:alt) || "",
      class: options.delete(:class) || "",
      decoding: "async"
    }.merge(intrinsic_dimensions(attachment, max_width: width, max_height: height))

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
  # fetchpriority는 기본 false다. 페이지마다 LCP 요소는 하나뿐이므로,
  # 모든 이미지에 high를 주면 브라우저의 우선순위 판단이 무력화되어 오히려 느려진다.
  def responsive_image_tag(source, sizes_attr: "(max-width: 1024px) 100vw, 1024px", lazy: true, fetchpriority: false, **options)
    return nil if source.blank?

    default_options = {
      alt: options.delete(:alt) || "",
      class: options.delete(:class) || "",
      decoding: "async",
      sizes: sizes_attr
    }

    default_options[:loading] = lazy ? "lazy" : "eager"

    if fetchpriority
      default_options[:fetchpriority] = "high"
    end

    if source.is_a?(ActiveStorage::Attached)
      return nil unless source.attached?

      srcset = Post::COVER_SRCSET_VARIANTS.map do |width, name|
        "#{url_for(source.variant(name))} #{width}w"
      end.join(", ")

      default_variant = source.variant(Post::COVER_SRCSET_VARIANTS.fetch(Post::COVER_DEFAULT_WIDTH))

      default_options[:srcset] = srcset
      default_options.merge!(intrinsic_dimensions(source, max_width: Post::COVER_DEFAULT_WIDTH))
      image_tag(default_variant, **default_options.merge(options))

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

    name = Post::COVER_SIZES.key?(size) ? size : :medium
    width, height = Post::COVER_SIZES.fetch(name)

    # WebP variant
    webp_variant = attachment.variant(name)

    # 원본 포맷 variant (폴백용). 미리 굽는 대상이 아니므로 요청 시 생성된다 —
    # 현재 이 메서드를 쓰는 뷰는 없다.
    fallback_variant = attachment.variant(
      resize_to_limit: [ width, height ]
    )

    loading_attr = lazy ? 'loading="lazy"' : 'fetchpriority="high"'
    alt_text = options[:alt] || ""
    css_class = options[:class] || ""

    content_tag(:picture) do
      concat tag(:source, type: "image/webp", srcset: url_for(webp_variant))
      concat image_tag(fallback_variant, alt: alt_text, class: css_class, decoding: "async", **options.except(:alt, :class))
    end
  end

  private

  # variant 가 실제로 갖게 될 표시 크기를 blob 메타데이터에서 계산한다.
  #
  # width/height 속성은 브라우저가 이미지 로드 전 자리를 잡는 aspect-ratio 힌트로
  # 쓰이고, 로드 후에도 그 비율이 박스를 지배한다. 따라서 값이 실제와 다르면
  # object-fit 이 없는 곳에서는 이미지가 그 비율로 늘어난다.
  #
  # 크기를 알 수 없으면 틀린 값을 쓰느니 속성을 생략한다. 레이아웃이 한 번
  # 흔들리는 편이 영구적으로 왜곡되는 것보다 낫다. (Active Storage 가 첨부 직후
  # 분석 잡을 큐에 넣으므로 이 경우는 분석 완료 전 짧은 순간에만 해당한다.)
  def intrinsic_dimensions(attachment, max_width:, max_height: nil)
    metadata = attachment.blob.metadata
    natural_width = metadata["width"].to_i
    natural_height = metadata["height"].to_i
    return {} unless natural_width.positive? && natural_height.positive?

    # resize_to_limit 은 축소만 하고 확대하지 않으므로 원본보다 커질 수 없다.
    scale = [ max_width.to_f / natural_width, 1.0 ].min
    scale = [ scale, max_height.to_f / natural_height ].min if max_height

    {
      width: (natural_width * scale).round,
      height: (natural_height * scale).round
    }
  end
end

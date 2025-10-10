module ImagesHelper
  def responsive_image_tag(image_path, alt_text: "", css_class: "", sizes: "640px", width: "", height: "")
    return image_placeholder(alt_text, css_class) if image_path.blank?

    # 기본 이미지 경로에서 파일명 추출 및 WebP로 변환
    original_filename = File.basename(image_path)
    base_name = File.basename(original_filename, ".*")
    webp_filename = "#{base_name}.webp"
    date_path = Time.current.strftime("%Y/%m")

    # srcset 생성
    srcset_urls = build_srcset(webp_filename, date_path)
    fallback_url = build_fallback_url(webp_filename, date_path)

    # 이미지 태그 옵션 설정
    image_options = {
      alt: alt_text,
      class: css_class,
      srcset: srcset_urls,
      sizes: sizes,
      width: width,
      height: height
    }

    # responsive image tag 생성
    image_tag fallback_url, image_options
  end

  def post_image_tag(post)
    if post.featured_image.present?
      responsive_image_tag(
        post.featured_image,
        alt_text: post.image_caption || post.title,
        sizes: "(max-width: 640px) 320px, (max-width: 960px) 600px, 960px"
      )
    else
      image_placeholder(post.title, "")
    end
  end

  def post_detail_image_tag(image_filename, alt_text: "", width: "2000", height: "1330")
    responsive_image_tag(
      image_filename,
      alt_text: alt_text,
      css_class: "kg-image",
      sizes: "(min-width: 720px) 720px",
      width: width,
      height: height
    )
  end

  private

  def build_srcset(filename, date_path)
    sizes = [
      { size: "w320", width: "320w" },
      { size: "w600", width: "600w" },
      { size: "w960", width: "960w" },
      { size: "w1200", width: "1200w" },
      { size: "w2000", width: "2000w" }
    ]

    srcset = sizes.map do |size_info|
      url = "/assets/images/size/#{size_info[:size]}/format/webp/#{date_path}/#{filename}"
      "#{url} #{size_info[:width]}"
    end

    srcset.join(", ")
  end

  def build_fallback_url(filename, date_path)
    "/assets/images/size/w600/format/webp/#{date_path}/#{filename}"
  end

  def image_placeholder(alt_text, css_class)
    content_tag :div, class: "#{css_class} image-placeholder" do
      content_tag :span, "#{alt_text.present? ? truncate(alt_text, length: 20) : "No Image"}"
    end
  end
end

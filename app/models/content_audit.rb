# frozen_string_literal: true

# 발행 전 콘텐츠 점검.
#
# 코드 품질 게이트(Brakeman/RuboCop/테스트)가 잡지 못하는 것들 — 본문 안에서만
# 드러나는 문제들 — 을 본다. 정적 분석 대상이 아니라 DB 에 들어 있는 데이터이므로,
# 실제 콘텐츠가 있는 곳을 향해 돌려야 의미가 있다. `rake content:check` 참고.
#
# 로직을 rake task 안이 아니라 여기 두는 이유는 테스트를 붙이기 위해서다.
class ContentAudit
  Finding = Struct.new(:post_id, :title, :check, :severity, :detail, keyword_init: true)

  # 검색 결과 스니펫과 카드 UI 가 쓰기에 부족하지 않을 최소치.
  SUMMARY_MIN_LENGTH = 50
  # 시리즈 접두사가 길어지면 실제 주제가 목록에서 잘려 나간다.
  TITLE_MAX_LENGTH = 40
  # 표지 원본은 어떤 뷰에서도 그대로 나가지 않는다. 모든 렌더 경로가
  # ImageHelper 를 거쳐 WebP variant 를 만들어 쓰므로, 원본에서 볼 것은
  # 바이트 수가 아니라 그 variant 들을 감당할 수 있는 폭인지다.
  #
  # 위: responsive_image_tag 가 만드는 가장 큰 srcset 폭. 이보다 넓은 부분은
  # 어떤 variant 로도 쓰이지 않으면서 variant 를 만들 때마다 디코딩 비용만 더한다.
  COVER_MAX_WIDTH = 1920
  # 아래: 상세 페이지 히어로의 표시 폭(sizes 속성 기준). resize_to_limit 은
  # 확대하지 않으므로, 원본이 이보다 좁으면 LCP 이미지가 그대로 흐리게 나간다.
  COVER_MIN_WIDTH = 1024
  # 스크린리더가 그대로 읽어 버려 빈 alt 보다 오히려 나쁜 값들.
  PLACEHOLDER_ALT = /\A(uploaded image|image|img|untitled)\z/i

  def self.run(scope = Post.all) = new(scope).run

  def initialize(scope = Post.all)
    @scope = scope
  end

  def run
    @findings = []
    @slugs = Post.pluck(:slug).compact_blank.to_set
    @ids = Post.pluck(:id).map(&:to_s).to_set

    @scope.includes(:tags, :rich_text_content, cover_image_attachment: :blob).find_each do |post|
      body = post.content&.body_before_type_cast.to_s

      check_summary(post)
      check_title(post)
      check_tags(post)
      check_cover(post)
      check_images(post, body)
      check_internal_links(post, body)
    end

    @findings
  end

  private

  def add(post, check, severity, detail)
    @findings << Finding.new(post_id: post.id, title: post.title.to_s, check: check,
                             severity: severity, detail: detail)
  end

  def check_summary(post)
    length = post.summary.to_s.strip.length
    return if length >= SUMMARY_MIN_LENGTH

    add(post, :summary_too_short, :warning,
        length.zero? ? "요약 없음" : "요약 #{length}자 (최소 #{SUMMARY_MIN_LENGTH}자)")
  end

  def check_title(post)
    length = post.title.to_s.length
    return if length <= TITLE_MAX_LENGTH

    add(post, :title_too_long, :warning, "제목 #{length}자 (권장 #{TITLE_MAX_LENGTH}자 이하)")
  end

  def check_tags(post)
    add(post, :no_tags, :warning, "태그 없음") if post.tags.empty?
  end

  def check_cover(post)
    unless post.cover_image.attached?
      add(post, :cover_missing, :warning, "표지 이미지 없음")
      return
    end

    blob = post.cover_image.blob
    # 분석 전이면 ImageHelper 가 width/height 를 생략하고, 그러면 aspect-ratio 가
    # 잡히지 않아 카드와 히어로에서 레이아웃 시프트가 난다.
    unless blob.analyzed?
      add(post, :cover_unanalyzed, :error, "표지 미분석 (#{blob.filename})")
      # 분석 전에는 폭을 알 수 없다. 짐작하지 않고 치수 검사를 건너뛴다.
      return
    end

    width = blob.metadata["width"].to_i
    return unless width.positive?

    if width > COVER_MAX_WIDTH
      add(post, :cover_oversized, :warning,
          "표지 폭 #{width}px — #{COVER_MAX_WIDTH}px 초과분은 variant 로 쓰이지 않는다 (#{blob.filename})")
    elsif width < COVER_MIN_WIDTH
      add(post, :cover_undersized, :warning,
          "표지 폭 #{width}px — 히어로 표시 폭 #{COVER_MIN_WIDTH}px 보다 좁아 확대 없이 흐리게 나간다 (#{blob.filename})")
    end
  end

  def check_images(post, body)
    body.scan(/<img\b[^>]*>/i).each do |tag|
      alt = tag[/\salt\s*=\s*"([^"]*)"/i, 1]
      if alt.nil?
        add(post, :image_alt_missing, :error, "alt 속성 없음 — #{src_name(tag)}")
      elsif alt.strip.empty?
        add(post, :image_alt_missing, :error, "alt 가 비어 있음 — #{src_name(tag)}")
      elsif alt.strip.match?(PLACEHOLDER_ALT)
        add(post, :image_alt_placeholder, :error, %(alt="#{alt}" 는 자리표시자 — #{src_name(tag)}))
      end
    end

    # redirect 라우트는 302 뒤에 max-age=300, private 을 붙여 Cloudflare 가 캐시하지
    # 못한다. 본문 이미지도 표지와 같이 proxy 경로로 나가야 한다.
    count = body.scan(%r{/rails/active_storage/(?:blobs|representations)/redirect/}).size
    add(post, :image_redirect_route, :error, "CDN 이 캐시할 수 없는 redirect 경로 #{count}개") if count.positive?
  end

  def check_internal_links(post, body)
    body.scan(/href="([^"]*)"/i).flatten.each do |href|
      path = percent_decode(href.split(/[?#]/).first.to_s)

      # 링크 필드에 설명문이 통째로 들어간 오조작. 경로에 섞인 공백이 신호다.
      # 쿼리스트링은 떼어 내고 본다 — `?q=build+tools` 처럼 `+` 가 공백을 뜻하는
      # 정상 URL 을 깨진 링크로 오해하지 않기 위해서다.
      if path.match?(/\s/)
        add(post, :malformed_link, :error, path.truncate(80))
        next
      end

      next unless internal_post_link?(href)

      key = path.split("/posts/").last.to_s
      next if key.empty? || @slugs.include?(key) || @ids.include?(key)

      add(post, :broken_internal_link, :error, path.truncate(80))
    end
  end

  # 남의 사이트에도 /posts/ 는 있다. 상대 경로이거나 우리 호스트일 때만 본다.
  def internal_post_link?(href)
    return true if href.start_with?("/posts/")
    return false unless href.include?("/posts/")

    host = URI.parse(href).host
    host.present? && host.delete_prefix("www.") == app_host
  rescue URI::InvalidURIError
    false
  end

  def app_host
    @app_host ||= ENV.fetch("APP_HOST", "kamillee0918.blog").delete_prefix("www.")
  end

  def src_name(tag)
    tag[/src="[^"]*\/([^\/"?]+)"/i, 1] || "(src 불명)"
  end

  # %XX 만 푼다. CGI.unescape 는 `+` 도 공백으로 바꾸는데, 경로에서 `+` 는 공백이
  # 아니라 그냥 문자다. 그걸 공백으로 되돌리면 멀쩡한 링크가 깨진 것처럼 보인다.
  def percent_decode(str)
    str.gsub(/%([0-9A-Fa-f]{2})/) { [ Regexp.last_match(1) ].pack("H*") }
       .force_encoding(Encoding::UTF_8)
       .scrub
  end
end

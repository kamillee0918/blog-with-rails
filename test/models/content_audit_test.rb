require "test_helper"

class ContentAuditTest < ActiveSupport::TestCase
  # 개별 검사를 격리해서 보려고, 만든 글 하나만 감사한다.
  def audit(post)
    ContentAudit.run(Post.where(id: post.id))
  end

  def checks_for(post)
    audit(post).map(&:check)
  end

  # 치수 검사를 보려면 분석된 blob 이 필요한데, 픽스처는 48x25 라 실제 분석으로는
  # 원하는 폭을 만들 수 없다. 분석 결과만 원하는 값으로 바꿔 끼운다.
  def attach_cover(post, width:, height:, byte_size: nil)
    post.cover_image.attach(io: file_fixture("test_image.png").open,
                            filename: "test_image.png", content_type: "image/png")
    blob = post.cover_image.blob
    blob.update!(metadata: blob.metadata.merge("width" => width, "height" => height, "analyzed" => true))
    blob.update!(byte_size: byte_size) if byte_size
    post.reload
  end

  def create_post(**attrs)
    Post.create!({ title: "Some Post", category: "Test", published_at: 1.day.ago,
                   summary: "이 글은 요약 길이 검사를 통과할 만큼 충분히 긴 설명을 담고 있으며, " \
                            "검색 결과 스니펫과 카드 UI 에서도 정보량이 부족하지 않습니다." }.merge(attrs))
  end

  test "깨끗한 글에서는 본문 관련 지적이 나오지 않는다" do
    post = create_post(content: '<p>본문</p><img src="/x.png" alt="설명이 있는 이미지">')
    post.tag_list = "ruby"

    found = checks_for(post)
    assert_not_includes found, :image_alt_missing
    assert_not_includes found, :broken_internal_link
    assert_not_includes found, :summary_too_short
    assert_not_includes found, :no_tags
  end

  # === 내부 링크 ===

  test "존재하지 않는 slug 로 가는 내부 링크를 잡는다" do
    post = create_post(title: "Linker", content: '<a href="/posts/nope-not-here">x</a>')

    assert_includes checks_for(post), :broken_internal_link
  end

  test "존재하는 slug 로 가는 내부 링크는 통과한다" do
    create_post(title: "Target Post")
    post = create_post(title: "Linker Two", content: '<a href="/posts/target-post">x</a>')

    assert_not_includes checks_for(post), :broken_internal_link
  end

  test "slug 가 없는 글은 id 로 링크해도 통과한다" do
    target = create_post(title: "한국어 제목")
    assert_nil target.slug
    post = create_post(title: "Linker Three", content: %(<a href="/posts/#{target.id}">x</a>))

    assert_not_includes checks_for(post), :broken_internal_link
  end

  test "절대 URL 로 쓴 내부 링크도 검사한다" do
    post = create_post(title: "Linker Four",
                       content: '<a href="https://kamillee0918.blog/posts/nope-not-here">x</a>')

    assert_includes checks_for(post), :broken_internal_link
  end

  test "남의 사이트의 /posts/ 링크는 건드리지 않는다" do
    post = create_post(title: "Linker Five",
                       content: '<a href="https://example.com/posts/whatever">x</a>')

    assert_not_includes checks_for(post), :broken_internal_link
  end

  test "URL 필드에 설명문이 들어간 오조작을 잡는다" do
    post = create_post(title: "Broken Href",
                       content: '<a href="https://kamillee0918.blog/코드%20및%20모델:%20MIT%20License">LICENSE</a>')

    assert_includes checks_for(post), :malformed_link
  end

  # 쿼리스트링의 `+` 는 공백을 뜻하지만 경로의 `+` 는 그냥 문자다. 이걸 구분하지
  # 않고 CGI.unescape 로 통째로 풀면 멀쩡한 링크가 깨진 것으로 보고된다.
  test "쿼리스트링에 + 가 있는 정상 링크를 오탐하지 않는다" do
    post = create_post(title: "Plus Query",
                       content: '<a href="https://visualstudio.microsoft.com/downloads/?q=build+tools#x">VS</a>')

    assert_not_includes checks_for(post), :malformed_link
    assert_not_includes checks_for(post), :broken_internal_link
  end

  # === 이미지 ===

  test "alt 가 없거나 비었으면 잡는다" do
    no_alt = create_post(title: "No Alt", content: '<img src="/a.png">')
    empty = create_post(title: "Empty Alt", content: '<img src="/b.png" alt="">')

    assert_includes checks_for(no_alt), :image_alt_missing
    assert_includes checks_for(empty), :image_alt_missing
  end

  test "자리표시자 alt 를 따로 구분해 잡는다" do
    post = create_post(title: "Placeholder Alt", content: '<img src="/c.png" alt="Uploaded image">')

    assert_includes checks_for(post), :image_alt_placeholder
  end

  test "CDN 이 캐시할 수 없는 redirect 경로를 잡는다" do
    post = create_post(
      title: "Redirect Route",
      content: '<img src="/rails/active_storage/blobs/redirect/abc/x.png" alt="설명">'
    )

    assert_includes checks_for(post), :image_redirect_route
  end

  test "proxy 경로는 통과한다" do
    post = create_post(
      title: "Proxy Route",
      content: '<img src="/rails/active_storage/blobs/proxy/abc/x.png" alt="설명">'
    )

    assert_not_includes checks_for(post), :image_redirect_route
  end

  # === 메타데이터 ===

  test "짧은 요약을 잡는다" do
    post = create_post(title: "Short Summary", summary: "너무 짧음")

    assert_includes checks_for(post), :summary_too_short
  end

  test "긴 제목을 잡는다" do
    post = create_post(title: "가" * (ContentAudit::TITLE_MAX_LENGTH + 1))

    assert_includes checks_for(post), :title_too_long
  end

  test "태그 없는 글을 잡는다" do
    post = create_post(title: "No Tags Here")

    assert_includes checks_for(post), :no_tags
  end

  test "표지 없는 글을 잡는다" do
    post = create_post(title: "No Cover")

    assert_includes checks_for(post), :cover_missing
  end

  # 분석 전이면 ImageHelper 가 width/height 를 생략하고, 그러면 aspect-ratio 가
  # 잡히지 않아 레이아웃 시프트가 난다. 표지 28장이 전부 이 상태였던 적이 있다.
  test "미분석 표지를 잡는다" do
    post = create_post(title: "Unanalyzed Cover")
    post.cover_image.attach(io: file_fixture("test_image.png").open,
                            filename: "test_image.png", content_type: "image/png")

    assert_includes checks_for(post), :cover_unanalyzed
  end

  test "분석된 표지는 통과한다" do
    post = create_post(title: "Analyzed Cover")
    post.cover_image.attach(io: file_fixture("test_image.png").open,
                            filename: "test_image.png", content_type: "image/png")
    post.cover_image.blob.analyze

    assert_not_includes checks_for(post), :cover_unanalyzed
  end

  # 표지 원본은 어떤 뷰에서도 그대로 나가지 않는다 — 전부 WebP variant 를 거친다.
  # 그래서 원본에서 볼 것은 파일 크기가 아니라 variant 들이 쓸 수 있는 폭이다.

  test "가장 큰 srcset 폭보다 넓은 표지를 잡는다" do
    post = create_post(title: "Oversized Cover")
    attach_cover(post, width: ContentAudit::COVER_MAX_WIDTH + 1, height: 1000)

    assert_includes checks_for(post), :cover_oversized
  end

  test "히어로 표시 폭보다 좁은 표지를 잡는다" do
    post = create_post(title: "Undersized Cover")
    attach_cover(post, width: ContentAudit::COVER_MIN_WIDTH - 1, height: 800)

    assert_includes checks_for(post), :cover_undersized
  end

  test "표시 폭과 최대 srcset 폭 사이의 표지는 통과한다" do
    post = create_post(title: "Right Sized Cover")
    attach_cover(post, width: 1440, height: 960)

    found = checks_for(post)
    assert_not_includes found, :cover_oversized
    assert_not_includes found, :cover_undersized
  end

  # 용량은 더 이상 보지 않는다. 원본이 서빙되지 않으므로 독자에게 닿는 비용이
  # 아니고, 임계값을 500KB 로 두었을 때 표지 28장이 전부 걸려 신호가 되지 못했다.
  test "폭이 적당하면 원본이 커도 지적하지 않는다" do
    post = create_post(title: "Heavy But Right Sized")
    attach_cover(post, width: 1600, height: 1067, byte_size: 12.megabytes)

    assert_empty checks_for(post).select { |c| c.to_s.start_with?("cover_") }
  end

  test "심각도가 error 와 warning 으로 나뉜다" do
    post = create_post(title: "Mixed", summary: "짧음", content: '<img src="/a.png">')

    findings = audit(post)
    assert_includes findings.select { |f| f.severity == :error }.map(&:check), :image_alt_missing
    assert_includes findings.select { |f| f.severity == :warning }.map(&:check), :summary_too_short
  end

  test "기본 스코프는 전체 글이다" do
    create_post(title: "Scan Me", content: '<img src="/a.png">')

    assert_includes ContentAudit.run.map(&:check), :image_alt_missing
  end
end

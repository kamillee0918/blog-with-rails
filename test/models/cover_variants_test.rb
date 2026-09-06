require "test_helper"

# 표지 variant 는 Post 의 선언과 ImageHelper 의 참조가 한 쌍으로 맞아야만 의미가 있다.
# 어긋나면 미리 구워 둔 파일과 뷰가 요청하는 키가 달라져, preprocessed 를 붙여 놓고도
# 방문자 요청 안에서 libvips 가 다시 도는 예전 상태로 조용히 되돌아간다.
class CoverVariantsTest < ActiveSupport::TestCase
  include ActionView::TestCase::Behavior
  include ActiveJob::TestHelper

  def create_post(**attrs)
    Post.create!({ title: "Cover Post", category: "Test", published_at: 1.day.ago }.merge(attrs))
  end

  def attach_cover(post)
    post.cover_image.attach(io: file_fixture("test_image.png").open,
                            filename: "test_image.png", content_type: "image/png")
    post.reload
  end

  # 이 테스트가 이 파일의 핵심이다.
  #
  # named variant 로 옮기기 전, 헬퍼는 아래 해시들을 그대로 넘겼다. 볼륨에 이미
  # 구워져 있는 WebP 는 그 해시로 만든 키 아래 있으므로, 이름으로 부를 때 같은 키가
  # 나오지 않으면 배포 순간 28장의 표지 variant 가 전부 무효화되고 방문자 요청
  # 안에서 다시 만들어진다 — 줄이려던 메모리 피크를 오히려 한 번에 몰아 받는다.
  # 비교 대상은 "예전 헬퍼가 실제로 하던 호출"이다. Active Storage 는 해시를
  # 그대로 쓰지 않고 format 을 앞으로 끌어올린 뒤 서명하므로, 날 해시로 만든
  # Variation 과 비교하면 순서만 달라 늘 어긋난다. 볼륨에 있는 파일의 키는
  # 어디까지나 attachment#variant 를 거쳐 나온 것이므로 그쪽과 맞춰야 한다.
  test "named variant 는 예전 인라인 해시와 같은 키를 만든다" do
    cover = attach_cover(create_post).cover_image

    Post::COVER_SRCSET_VARIANTS.each do |width, name|
      legacy = { resize_to_limit: [ width, nil ], format: :webp, saver: { quality: 80 } }

      assert_equal cover.variant(legacy).variation.key,
                   cover.variant(name).variation.key,
                   "srcset #{width}w 의 키가 바뀌었다 — 볼륨의 기존 variant 가 무효화된다"
    end
  end

  test "프리셋 named variant 도 예전 인라인 해시와 같은 키를 만든다" do
    cover = attach_cover(create_post).cover_image

    Post::COVER_SIZES.each do |name, (width, height)|
      legacy = { resize_to_limit: [ width, height ], format: :webp, saver: { quality: 80 } }

      assert_equal cover.variant(legacy).variation.key,
                   cover.variant(name).variation.key,
                   ":#{name} 의 키가 바뀌었다 — 볼륨의 기존 variant 가 무효화된다"
    end
  end

  # 굽는 대상은 뷰가 요청하는 것과 정확히 같아야 한다. 모자라면 요청 경로에
  # libvips 가 남고, 넘치면 아무도 안 보는 파일이 볼륨을 먹는다.
  test "미리 굽는 variant 는 뷰가 실제로 요청하는 것과 일치한다" do
    assert_equal (Post::COVER_SRCSET_VARIANTS.values + [ :small ]).sort,
                 Post::PREPROCESSED_COVER_VARIANTS.sort
  end

  test "표지를 붙이면 미리 구울 variant 만큼 TransformJob 이 큐에 들어간다" do
    post = create_post

    assert_enqueued_jobs Post::PREPROCESSED_COVER_VARIANTS.size, only: ActiveStorage::TransformJob do
      attach_cover(post)
    end
  end

  # 표지 공유(cover:reuse)는 attachment 를 새로 만들므로 잡이 다시 걸리지만,
  # 같은 blob 이라 variant 는 이미 있다. 다시 굽지 않고 지나가야 한다.
  test "이미 구워 둔 blob 을 다른 글에 붙여도 variant 를 다시 만들지 않는다" do
    source = attach_cover(create_post(title: "Source Post"))
    CoverBlobs.warm

    target = create_post(title: "Target Post")

    assert_no_difference -> { ActiveStorage::VariantRecord.count } do
      target.cover_image.attach(source.cover_image.blob)
      CoverBlobs.warm
    end
  end

  test "warm 은 아직 없는 variant 만 만들고 두 번째 실행에서는 아무것도 만들지 않는다" do
    attach_cover(create_post)

    first = CoverBlobs.warm
    assert_equal 1, first.covers
    assert_equal Post::PREPROCESSED_COVER_VARIANTS.size, first.built
    assert_empty first.errors

    second = CoverBlobs.warm
    assert_equal 0, second.built
  end

  test "warm 은 표지가 없는 글을 건너뛴다" do
    create_post(title: "No Cover")

    result = CoverBlobs.warm

    assert_equal 0, result.covers
    assert_equal 0, result.built
  end

  # 헬퍼가 인라인 해시로 되돌아가면 preprocessed 가 통째로 무의미해지므로,
  # 뷰가 내놓는 URL 이 미리 구워 둔 variant 의 것과 같은지 확인한다.
  test "responsive_image_tag 는 미리 구워 둔 srcset variant 를 가리킨다" do
    post = attach_cover(create_post)
    CoverBlobs.warm

    html = view.responsive_image_tag(post.cover_image, alt: post.title)
    srcset = Nokogiri::HTML5.fragment(html).at_css("img")["srcset"]

    Post::COVER_SRCSET_VARIANTS.each do |width, name|
      expected = view.url_for(post.cover_image.variant(name))

      assert_includes srcset, "#{expected} #{width}w",
                      "srcset 의 #{width}w 가 미리 구워 둔 variant 를 가리키지 않는다"
    end
  end

  test "optimized_image_tag 는 프리셋 named variant 를 가리킨다" do
    post = attach_cover(create_post)

    html = view.optimized_image_tag(post.cover_image, size: :small)
    src = Nokogiri::HTML5.fragment(html).at_css("img")["src"]

    # image_tag 는 절대 URL 을 내므로 경로만 비교한다.
    assert_equal view.url_for(post.cover_image.variant(:small)), URI.parse(src).request_uri
  end
end

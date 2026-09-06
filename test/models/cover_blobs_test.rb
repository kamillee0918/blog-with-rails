require "test_helper"

class CoverBlobsTest < ActiveSupport::TestCase
  def create_post(**attrs)
    Post.create!({ title: "Some Post", category: "Test", published_at: 1.day.ago }.merge(attrs))
  end

  def attach_cover(post)
    post.cover_image.attach(io: file_fixture("test_image.png").open,
                            filename: "test_image.png", content_type: "image/png")
    post.reload
  end

  test "원본 글의 blob 을 그대로 붙이고 파일을 새로 만들지 않는다" do
    source = attach_cover(create_post(title: "Source Post"))
    target = create_post(title: "Target Post")

    result = nil
    assert_no_difference -> { ActiveStorage::Blob.count } do
      result = CoverBlobs.reuse(source: "source-post", target: "target-post")
    end

    assert_equal :attached, result.status
    assert_equal source.cover_image.blob.id, target.reload.cover_image.blob.id
  end

  test "이미 같은 blob 을 쓰고 있으면 다시 붙이지 않는다" do
    source = attach_cover(create_post(title: "Source Post"))
    target = create_post(title: "Target Post")
    target.cover_image.attach(source.cover_image.blob)

    result = nil
    assert_no_difference -> { ActiveStorage::Attachment.count } do
      result = CoverBlobs.reuse(source: "source-post", target: "target-post")
    end

    assert_equal :unchanged, result.status
  end

  test "다른 표지가 이미 있으면 force 없이는 바꾸지 않는다" do
    attach_cover(create_post(title: "Source Post"))
    target = attach_cover(create_post(title: "Target Post"))
    original_blob_id = target.cover_image.blob.id

    result = CoverBlobs.reuse(source: "source-post", target: "target-post")

    assert_equal :blocked, result.status
    assert_equal original_blob_id, target.reload.cover_image.blob.id
  end

  test "force 를 주면 기존 표지를 원본 글의 blob 으로 교체한다" do
    source = attach_cover(create_post(title: "Source Post"))
    target = attach_cover(create_post(title: "Target Post"))

    result = CoverBlobs.reuse(source: "source-post", target: "target-post", force: true)

    assert_equal :attached, result.status
    assert_equal source.cover_image.blob.id, target.reload.cover_image.blob.id
  end

  test "아직 공개되지 않은 글에도 붙일 수 있다" do
    attach_cover(create_post(title: "Source Post"))
    target = create_post(title: "Target Post", published_at: 1.month.from_now)

    result = CoverBlobs.reuse(source: "source-post", target: "target-post")

    assert_equal :attached, result.status
    assert target.reload.cover_image.attached?
  end

  test "slug 가 없는 글은 id 로 찾는다" do
    attach_cover(create_post(title: "Source Post"))
    target = create_post(title: "한국어 제목")
    assert_nil target.slug

    result = CoverBlobs.reuse(source: "source-post", target: target.id.to_s)

    assert_equal :attached, result.status
  end

  test "원본 글에 표지가 없으면 붙일 blob 이 없다고 알린다" do
    create_post(title: "Source Post")
    create_post(title: "Target Post")

    assert_raises(CoverBlobs::Error) do
      CoverBlobs.reuse(source: "source-post", target: "target-post")
    end
  end

  test "없는 글을 지정하면 어느 쪽을 못 찾았는지 알려 준다" do
    attach_cover(create_post(title: "Source Post"))

    error = assert_raises(ActiveRecord::RecordNotFound) do
      CoverBlobs.reuse(source: "source-post", target: "nope-not-here")
    end

    assert_includes error.message, "nope-not-here"
  end

  # 이 글의 표지 공유는 attachments 의 외래 키가 blob 을 지켜 준다는 전제 위에 서 있다.
  # 전제가 무너지면 한쪽 글을 정리하는 순간 다른 글의 표지가 사라지므로, 여기서 못 박아 둔다.
  test "공유 중인 blob 은 한쪽에서 떼어내도 파일이 남는다" do
    source = attach_cover(create_post(title: "Source Post"))
    target = create_post(title: "Target Post")
    CoverBlobs.reuse(source: "source-post", target: "target-post")
    blob = source.cover_image.blob

    target.reload.cover_image.purge

    assert ActiveStorage::Blob.exists?(blob.id), "blob 행이 사라졌다"
    assert ActiveStorage::Blob.service.exist?(blob.key), "실제 파일이 사라졌다"
    assert source.reload.cover_image.attached?
  end
end

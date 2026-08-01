require "test_helper"

class ImageHelperTest < ActionView::TestCase
  # 브라우저는 width/height 속성으로 aspect-ratio 를 잡고 로드 후에도 그 비율을
  # 유지하므로, 값이 실제와 다르면 object-fit 이 없는 자리에서 이미지가 늘어난다.
  # 따라서 이 계산은 원본 비율을 반드시 보존해야 한다.
  FakeBlob = Struct.new(:metadata)
  FakeAttachment = Struct.new(:blob)

  def dimensions_for(width, height, **limits)
    attachment = FakeAttachment.new(FakeBlob.new({ "width" => width, "height" => height }))
    send(:intrinsic_dimensions, attachment, **limits)
  end

  test "scales down to the width limit while preserving the ratio" do
    assert_equal({ width: 1024, height: 683 }, dimensions_for(3000, 2000, max_width: 1024))
  end

  test "does not upscale an image smaller than the limit" do
    assert_equal({ width: 640, height: 400 }, dimensions_for(640, 400, max_width: 1024))
  end

  test "respects a height cap as well as a width cap" do
    assert_equal({ width: 375, height: 250 },
                 dimensions_for(3000, 2000, max_width: 380, max_height: 250))
  end

  test "limits a tall image by width only when no height cap is given" do
    assert_equal({ width: 1024, height: 1536 }, dimensions_for(1200, 1800, max_width: 1024))
  end

  # 분석 잡이 끝나기 전에는 크기를 알 수 없다. 틀린 값을 넣어 영구히 왜곡시키느니
  # 속성을 생략하고 레이아웃이 한 번 흔들리게 두는 편이 낫다.
  test "omits dimensions when the blob has no analyzed size" do
    assert_empty dimensions_for(nil, nil, max_width: 1024)
  end
end

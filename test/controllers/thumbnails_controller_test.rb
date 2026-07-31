require "test_helper"

class ThumbnailsControllerTest < ActionDispatch::IntegrationTest
  # app/assets/images/thumbnail/ 에 실제로 존재하는 파일
  EXISTING_IMAGE = "dummy_thumbnail.png"

  test "width 없이 요청하면 원본을 그대로 서빙한다" do
    get thumbnail_path(filename: EXISTING_IMAGE)

    assert_response :success
  end

  # 이 테스트는 ImageProcessing::Vips 파이프라인을 실제로 실행한다.
  # 이미지 백엔드 젬(ruby-vips)이 번들에서 빠지면 여기서 실패한다.
  # test 환경은 cache_store가 :null_store이므로 항상 실제 리사이즈가 수행된다.
  test "width 지정 시 vips로 리사이즈한 이미지를 반환한다" do
    get thumbnail_path(filename: EXISTING_IMAGE, width: 120)

    assert_response :success
    assert_equal "image/png", response.media_type
    assert_operator response.body.bytesize, :>, 0
  end

  test "존재하지 않는 파일은 404를 반환한다" do
    get thumbnail_path(filename: "definitely_missing_file.png")

    assert_response :not_found
  end

  test "허용 디렉터리 밖의 파일은 서빙하지 않는다" do
    get thumbnail_path(filename: "../../../config/database.yml")

    assert_not_equal 200, response.status
  end
end

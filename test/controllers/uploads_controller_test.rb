require "test_helper"

class UploadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = admins(:one)
  end

  # 세 번째 인자(binary)를 켜지 않으면 Rack::Test 가 파일을 텍스트 모드로 읽는다.
  # Windows 에서는 그 탓에 CRLF 가 LF 로 바뀌고 0x1A(DOS EOF)에서 스트림이 끊겨
  # 2,683바이트 PNG 가 5바이트로 잘린다. 그러면 vips 가 분석에 실패하고
  # UploadsController 의 `metadata["width"] || 1020` 폴백이 대신 응답한다.
  # Linux 에서는 두 모드가 같아 CI 에서는 드러나지 않는다.
  def png_upload
    fixture_file_upload("test_image.png", "image/png", :binary)
  end

  test "rejects anonymous uploads" do
    post uploads_image_url, params: { file: png_upload }
    assert_redirected_to login_path
  end

  test "rejects a file type that is not an image" do
    sign_in_as_admin
    post uploads_image_url,
         params: { file: fixture_file_upload("test_image.png", "application/x-msdownload") }

    assert_response :unprocessable_entity
    assert_match(/Invalid file type/, response.parsed_body["error"])
  end

  test "rejects a request with no file" do
    sign_in_as_admin
    post uploads_image_url

    assert_response :unprocessable_entity
  end

  test "stores the image and reports its analyzed size" do
    sign_in_as_admin
    assert_difference("ActiveStorage::Blob.count", 1) do
      post uploads_image_url, params: { file: png_upload }
    end

    assert_response :success
    body = response.parsed_body
    assert_equal 48, body["width"]
    assert_equal 25, body["height"]
    assert body["location"].present?
  end

  # redirect 라우트는 5분 만료 서명 URL 로 302 를 보내고 Cache-Control 에 private 이
  # 붙어 Cloudflare 가 캐시하지 못한다. 본문 이미지도 커버 이미지와 같이
  # proxy 경로로 나가야 CDN 이 캐시할 수 있다.
  test "serves editor images through the CDN-cacheable proxy route" do
    sign_in_as_admin
    post uploads_image_url, params: { file: png_upload }

    body = response.parsed_body
    assert_includes body["location"], "/rails/active_storage/blobs/proxy/"
    assert_not_includes body["location"], "/redirect/"
    assert_includes body["srcset"], body["location"]
  end

  test "builds a srcset of proxy variant URLs for a wide image" do
    sign_in_as_admin
    post uploads_image_url,
         params: { file: fixture_file_upload("wide_image.png", "image/png", :binary) }

    body = response.parsed_body
    assert_equal 1200, body["width"]

    entries = body["srcset"].split(", ")
    # 원본(1200w)보다 좁은 프리셋만 포함된다.
    expected = UploadsController::SRCSET_WIDTHS.select { |w| w <= 1200 }
    assert_equal expected.size + 1, entries.size

    variant_entries = entries.reject { |e| e.end_with?("1200w") }
    assert variant_entries.all? { |e| e.include?("/rails/active_storage/representations/proxy/") },
           "variant URL 이 proxy 경로가 아니다: #{variant_entries.first}"
  end
end

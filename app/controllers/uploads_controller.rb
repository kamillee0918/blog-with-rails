# frozen_string_literal: true

# TinyMCE Editor 이미지 업로드를 처리하는 컨트롤러
# TinyMCE는 이미지 업로드 후 { "location": "https://..." } 형태의 JSON 응답을 기대함
class UploadsController < ApplicationController
  before_action :authenticate_admin!

  # 반응형 이미지를 위한 srcset 크기 정의
  SRCSET_WIDTHS = [ 380, 640, 768, 800, 1020, 1160, 1280 ].freeze

  # POST /uploads/image
  # TinyMCE Editor에서 이미지 업로드 시 호출됨
  def image
    file = params[:file] || params[:image]

    unless file.present?
      return render json: { error: "No file provided" }, status: :unprocessable_entity
    end

    # 허용된 이미지 타입 검증
    allowed_types = %w[image/jpeg image/png image/gif image/webp]
    unless allowed_types.include?(file.content_type)
      return render json: { error: "Invalid file type. Allowed: JPEG, PNG, GIF, WEBP" }, status: :unprocessable_entity
    end

    # 파일 크기 제한 (10MB)
    max_size = 10.megabytes
    if file.size > max_size
      return render json: { error: "File too large. Maximum size: 10MB" }, status: :unprocessable_entity
    end

    # ActiveStorage를 사용하여 이미지 저장
    blob = ActiveStorage::Blob.create_and_upload!(
      io: file,
      filename: file.original_filename,
      content_type: file.content_type
    )

    # 이미지 메타데이터 분석 (width, height)
    blob.analyze unless blob.analyzed?
    metadata = blob.metadata
    original_width = metadata["width"] || 1020
    original_height = metadata["height"] || 680

    # 원본 이미지 URL
    image_url = Rails.application.routes.url_helpers.rails_blob_url(blob, only_path: true)

    # srcset 생성 (원본보다 작은 크기만 포함)
    srcset_entries = []

    SRCSET_WIDTHS.each do |width|
      next if width > original_width

      # 비율 유지하여 높이 계산
      height = (original_height.to_f * width / original_width).round

      # ActiveStorage variant URL 생성
      variant_url = Rails.application.routes.url_helpers.rails_blob_representation_url(
        blob.signed_id,
        blob.representation(resize_to_limit: [ width, height ]).variation.key,
        blob.filename,
        only_path: true
      )
      srcset_entries << "#{variant_url} #{width}w"
    end

    # 원본 크기도 srcset에 추가
    srcset_entries << "#{image_url} #{original_width}w"

    # TinyMCE 응답 형식: { "location": "url" }
    render json: {
      location: image_url,
      width: original_width,
      height: original_height,
      srcset: srcset_entries.join(", "),
      sizes: "(max-width: 1020px) 100vw, 1020px"
    }
  end

  # DELETE /uploads/image
  # 이미지 삭제 시 호출됨 (선택적)
  def destroy_image
    # src 파라미터에서 blob의 signed_id 추출
    src = params[:src]

    if src.present?
      # URL에서 signed_id 추출 시도
      # 예: /rails/active_storage/blobs/redirect/:signed_id/:filename
      if src =~ %r{/rails/active_storage/blobs/(?:redirect|proxy)/([^/]+)/}
        signed_id = Regexp.last_match(1)
        begin
          blob = ActiveStorage::Blob.find_signed(signed_id)
          blob.purge if blob
        rescue ActiveSupport::MessageVerifier::InvalidSignature
          # 유효하지 않은 signed_id - 무시
        end
      end
    end

    head :ok
  end
end

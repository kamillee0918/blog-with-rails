class ThumbnailsController < ApplicationController
  include ActionController::Live

  def show
    # 라우트 제약(filename: /.+/)이 확장자까지 greedy하게 흡수하므로 params[:format]은
    # 보통 비어 있다. 확장자가 별도로 넘어온 경우까지 모두 처리한다.
    # File.basename으로 디렉터리 성분을 제거해 경로 탐색을 차단한다.
    safe_filename = File.basename(params[:filename].to_s)
    if params[:format].present?
      safe_filename = "#{safe_filename}.#{File.basename(params[:format])}"
    end
    width = params[:width].to_i

    if safe_filename.blank? || safe_filename.delete(".").blank?
      head :bad_request
      return
    end

    filename = safe_filename
    original_path = Rails.root.join("app/assets/images/thumbnail", safe_filename)

    # Extra security check: ensure path is within allowed directory
    allowed_dir = Rails.root.join("app/assets/images/thumbnail").to_s
    unless File.expand_path(original_path).start_with?(allowed_dir)
      head :bad_request
      return
    end

    unless File.exist?(original_path)
      head :not_found
      return
    end

    # If no width specified, serve original
    if width <= 0
      send_file original_path, disposition: :inline
      return
    end

    # Generate cache key
    cache_key = "thumbnail/#{filename}/#{width}"

    # Use Rails cache to store the processed image data
    # Note: For production, you might want to store these files on disk or use a CDN
    processed_data = Rails.cache.fetch(cache_key, expires_in: 1.month) do
      pipeline = ImageProcessing::Vips.source(original_path)

      # Resize maintaining aspect ratio
      processed = pipeline.resize_to_limit(width, nil).call

      File.binread(processed.path)
    end

    send_data processed_data,
              type: Mime::Type.lookup_by_extension(File.extname(safe_filename).delete_prefix(".")),
              disposition: :inline
  end
end

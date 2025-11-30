class ThumbnailsController < ApplicationController
  include ActionController::Live

  def show
    safe_name = File.basename(params[:filename].to_s)
    safe_ext = File.basename(params[:format].to_s)
    filename = "#{safe_name}.#{safe_ext}"
    width = params[:width].to_i

    # Prevent directory traversal and ensure safe filename
    safe_filename = File.basename(filename)
    if filename != safe_filename
      head :bad_request
      return
    end

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
              type: Mime::Type.lookup_by_extension(params[:format]),
              disposition: :inline
  end
end

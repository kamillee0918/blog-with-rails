require "mini_magick"

class ImageProcessor
  SIZES = {
    w320: { width: 320, height: 240 },
    w600: { width: 600, height: 450 },
    w960: { width: 960, height: 720 },
    w1200: { width: 1200, height: 900 },
    w2000: { width: 2000, height: 1499 }
  }.freeze

  def self.process_all_images(force: false)
    new.process_all_images(force: force)
  end

  def initialize
    @assets_path = Rails.root.join("app", "assets", "images")
    @public_path = Rails.root.join("public", "assets", "images")
  end

  def process_all_images(force: false)
    puts "🖼️  Processing images..."

    # assets/images 폴더의 모든 이미지 파일 찾기
    image_files = Dir.glob(@assets_path.join("**", "*.{jpg,jpeg,png,gif}"))

    if image_files.empty?
      puts "No images found in #{@assets_path}"
      return
    end

    image_files.each do |image_path|
      next if !force && already_processed?(image_path)

      begin
        process_single_image(image_path, force: force)
        puts "✅ Processed: #{File.basename(image_path)}"
      rescue => e
        puts "❌ Error processing #{File.basename(image_path)}: #{e.message}"
      end
    end

    puts "🎉 Image processing completed!"
  end

  private

  def process_single_image(image_path, force: false)
    original_filename = File.basename(image_path)
    base_name = File.basename(original_filename, ".*")  # 확장자 제거
    webp_filename = "#{base_name}.webp"  # WebP 확장자로 변경

    # 현재 날짜로 폴더 구조 생성 (YYYY/MM 형태)
    date_path = Time.current.strftime("%Y/%m")

    SIZES.each do |size_key, dimensions|
      begin
        # 대상 디렉토리 생성
        target_dir = @public_path.join("size", size_key.to_s, "format", "webp", date_path)
        FileUtils.mkdir_p(target_dir)

        # WebP 파일명으로 저장
        target_file = target_dir.join(webp_filename)

        # 이미 존재하는 파일은 건너뛰기 (force가 false인 경우)
        if !force && File.exist?(target_file)
          puts "  → Skipping existing #{size_key}: #{target_file}"
          next
        end

        # MiniMagick.convert를 사용하여 직접 변환 (더 효율적)
        MiniMagick.convert do |convert|
          convert << image_path
          convert.resize("#{dimensions[:width]}x#{dimensions[:height]}")  # 비율 유지
          convert.format("webp")
          convert << target_file.to_s
        end

        puts "  ✓ Created #{size_key}: #{target_file}"

      rescue => e
        puts "  ❌ Failed to create #{size_key} for #{original_filename}: #{e.message}"
        puts "  Debug: #{e.backtrace.first(3).join("\n         ")}"
        # 개별 크기 실패해도 다른 크기는 계속 처리
        next
      end
    end
  end

  def already_processed?(image_path)
    original_filename = File.basename(image_path)
    base_name = File.basename(original_filename, ".*")
    webp_filename = "#{base_name}.webp"
    date_path = Time.current.strftime("%Y/%m")

    # w320 사이즈가 존재하면 이미 처리된 것으로 판단
    check_path = @public_path.join("size", "w320", "format", "webp", date_path, webp_filename)
    File.exist?(check_path)
  end
end

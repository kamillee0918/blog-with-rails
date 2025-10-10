namespace :images do
  desc "Process all images (force regenerate)"
  task process: :environment do
    puts "🔄 Force processing all images..."
    ImageProcessor.process_all_images(force: true)
  end

  desc "Check processed images status"
  task status: :environment do
    assets_path = Rails.root.join("app", "assets", "images")
    public_path = Rails.root.join("public", "assets", "images")

    image_files = Dir.glob(assets_path.join("**", "*.{jpg,jpeg,png,gif}"))

    puts "📊 Image Processing Status"
    puts "=" * 50

    image_files.each do |image_path|
      original_filename = File.basename(image_path)
      base_name = File.basename(original_filename, ".*")
      webp_filename = "#{base_name}.webp"
      date_path = Time.current.strftime("%Y/%m")

      puts "\n📁 #{original_filename} → #{webp_filename}:"

      ImageProcessor::SIZES.keys.each do |size|
        target_file = public_path.join("size", size.to_s, "format", "webp", date_path, webp_filename)
        status = File.exist?(target_file) ? "✅" : "❌"
        puts "  #{status} #{size}"
      end
    end
  end

  desc "Clean all processed images"
  task clean: :environment do
    public_path = Rails.root.join("public", "assets", "images")
    if Dir.exist?(public_path)
      FileUtils.rm_rf(Dir.glob(public_path.join("*")))
      puts "🧹 Cleaned all processed images"
    else
      puts "📂 No processed images to clean"
    end
  end
end

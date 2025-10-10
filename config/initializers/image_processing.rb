Rails.application.config.after_initialize do
  # 개발 및 프로덕션 환경에서만 실행 (테스트 및 CI 환경 제외)
  unless Rails.env.test? || ENV['CI']
    begin
      ImageProcessor.process_all_images
    rescue => e
      Rails.logger.error "Image processing failed: #{e.message}"
      puts "⚠️  Image processing failed: #{e.message}"
    end
  end
end

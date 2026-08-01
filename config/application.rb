require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BlogWithRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # ActiveStorage 이미지 최적화 설정
    # WebP 포맷 지원 추가
    config.active_storage.web_image_content_types = %w[image/png image/jpeg image/jpg image/gif image/webp]

    # libvips 사용 (기본값, ImageMagick보다 빠름)
    config.active_storage.variant_processor = :vips

    # 이미지를 앱이 직접 내려준다(proxy). 기본값인 redirect 는 302 로 5분 만료
    # 서명 URL 을 가리키고 Cache-Control 에 private 이 붙어 앞단의 Cloudflare 가
    # 전혀 캐시하지 못한다. proxy 컨트롤러는 http_cache_forever public: true 를 쓰므로
    # CDN 이 캐시할 수 있고, 왕복도 2회에서 1회로 준다.
    # (service 가 Disk 라 redirect 의 두 번째 요청도 어차피 앱으로 들어온다)
    config.active_storage.resolve_model_to_route = :rails_storage_proxy

    # 동적 오류 페이지 사용 (public/*.html 대신 컨트롤러/뷰 사용)
    config.exceptions_app = self.routes
  end
end

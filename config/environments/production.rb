require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # === HTTP 캐싱 최적화 ===
  # 정적 에셋: 1년 캐시 + immutable (digest 포함이므로 안전)
  config.public_file_server.headers = {
    "cache-control" => "public, max-age=#{1.year.to_i}, immutable"
  }

  # ETag/조건부 GET: 컨트롤러에서 stale?/fresh_when 사용
  # rack-cache는 레거시 - Thruster가 HTTP 캐싱 처리

  # 동적 페이지 기본 캐시 헤더 (Cloudflare와 브라우저)
  # 개별 컨트롤러에서 fresh_when, stale? 로 세밀하게 제어 가능
  config.action_controller.default_static_extension = nil

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  # === Cloudflare Tunnel SSL 설정 ===
  # Cloudflare가 SSL을 처리하므로 Rails는 프록시 뒤에 있다고 가정
  config.assume_ssl = true

  # HTTPS 강제 및 Strict-Transport-Security 헤더 활성화
  config.force_ssl = true

  # Health check 엔드포인트는 SSL 리다이렉트에서 제외
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!).
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST", "example.com") }

  # Specify outgoing SMTP server. Remember to add smtp/* credentials via bin/rails credentials:edit.
  # config.action_mailer.smtp_settings = {
  #   user_name: Rails.application.credentials.dig(:smtp, :user_name),
  #   password: Rails.application.credentials.dig(:smtp, :password),
  #   address: "smtp.example.com",
  #   port: 587,
  #   authentication: :plain
  # }

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # === Host Authorization (DNS rebinding 방어) ===
  # 환경변수 ALLOWED_HOSTS로 허용 호스트 설정 (쉼표로 구분)
  # 예: ALLOWED_HOSTS="blog.example.com,www.example.com"
  if ENV["ALLOWED_HOSTS"].present?
    config.hosts = ENV["ALLOWED_HOSTS"].split(",").map(&:strip)
    config.hosts << /.*\.cfargotunnel\.com/  # Cloudflare Tunnel 내부 도메인 허용
  end

  # Health check 엔드포인트는 Host 검증에서 제외
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }
end

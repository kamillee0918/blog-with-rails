# frozen_string_literal: true

# 프로덕션 환경에서 추가 보안 헤더 설정
# Cloudflare에서도 설정 가능하지만, 이중 보안을 위해 Rails에서도 설정

if Rails.env.production?
  Rails.application.config.action_dispatch.default_headers.merge!(
    # 콘텐츠 타입 스니핑 방지
    "X-Content-Type-Options" => "nosniff",

    # 클릭재킹 방지 (동일 출처에서만 iframe 허용)
    "X-Frame-Options" => "SAMEORIGIN",

    # XSS 필터 활성화 (레거시 브라우저용)
    "X-XSS-Protection" => "1; mode=block",

    # Referrer 정책 (같은 출처는 전체, 다른 출처는 출처만)
    "Referrer-Policy" => "strict-origin-when-cross-origin",

    # HTTPS로만 접근 가능 (1년, 서브도메인 포함)
    # Cloudflare에서도 설정하지만 이중 보안
    "Strict-Transport-Security" => "max-age=31536000; includeSubDomains",

    # 권한 정책 (카메라, 마이크, 위치 등 브라우저 기능 제한)
    "Permissions-Policy" => "camera=(), microphone=(), geolocation=()"
  )
end

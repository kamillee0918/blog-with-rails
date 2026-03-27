# frozen_string_literal: true

# Content Security Policy (CSP) Configuration
# XSS 공격에 대한 브라우저 레벨 방어를 제공합니다.
# 참고: https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data, "https://cdn.jsdelivr.net", "https://sp.tinymce.com", "https://cdn.tiny.cloud"
    policy.img_src     :self, :data, :blob, "https:", "http:"
    policy.object_src  :none
    policy.script_src  :self,
                       "https://cdn.jsdelivr.net",        # PrismJS, MathJax, Mermaid
                       "https://cdn.tiny.cloud",          # TinyMCE Editor
                       "https://sp.tinymce.com",          # TinyMCE telemetry
                       "https://www.googletagmanager.com", # Google Tag Manager
                       "https://www.google-analytics.com", # Google Analytics
                       "https://static.cloudflareinsights.com", # Cloudflare Web Analytics
                       :unsafe_inline,                     # 인라인 스크립트 (GA, MathJax config 등)
                       :unsafe_eval                        # TinyMCE 내부 eval 필요
    policy.style_src   :self,
                       "https://cdn.jsdelivr.net",        # PrismJS CSS
                       "https://cdn.tiny.cloud",          # TinyMCE CSS
                       "https://sp.tinymce.com",          # TinyMCE
                       :unsafe_inline                     # 인라인 스타일 (layout CSS variables 등)
    policy.connect_src :self,
                       "https://cdn.jsdelivr.net",
                       "https://cdn.tiny.cloud",
                       "https://sp.tinymce.com",
                       "https://www.googletagmanager.com",
                       "https://www.google-analytics.com",
                       "https://analytics.google.com",
                       "https://static.cloudflareinsights.com" # Cloudflare Web Analytics RUM
    policy.frame_src   :self, "https://www.googletagmanager.com"
    policy.worker_src  :self, :blob
    policy.child_src   :self, :blob
    policy.media_src   :self
    policy.base_uri    :self
    policy.form_action :self
  end

  # Report violations without enforcing the policy (개발 단계에서 먼저 모니터링)
  # 충분히 테스트한 후 false로 변경하여 실제 차단 적용
  config.content_security_policy_report_only = true
end

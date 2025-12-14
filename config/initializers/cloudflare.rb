# frozen_string_literal: true

# Cloudflare Tunnel 환경 설정
# Cloudflare를 통해 들어오는 요청의 실제 클라이언트 IP를 인식하기 위한 설정

if Rails.env.production?
  # Cloudflare IP 범위를 신뢰할 수 있는 프록시로 설정
  # https://www.cloudflare.com/ips/
  CLOUDFLARE_IPS = %w[
    173.245.48.0/20
    103.21.244.0/22
    103.22.200.0/22
    103.31.4.0/22
    141.101.64.0/18
    108.162.192.0/18
    190.93.240.0/20
    188.114.96.0/20
    197.234.240.0/22
    198.41.128.0/17
    162.158.0.0/15
    104.16.0.0/13
    104.24.0.0/14
    172.64.0.0/13
    131.0.72.0/22
  ].freeze

  # IPv6 범위
  CLOUDFLARE_IPV6 = %w[
    2400:cb00::/32
    2606:4700::/32
    2803:f800::/32
    2405:b500::/32
    2405:8100::/32
    2a06:98c0::/29
    2c0f:f248::/32
  ].freeze

  Rails.application.config.action_dispatch.trusted_proxies =
    ActionDispatch::RemoteIp::TRUSTED_PROXIES +
    CLOUDFLARE_IPS.map { |ip| IPAddr.new(ip) } +
    CLOUDFLARE_IPV6.map { |ip| IPAddr.new(ip) }
end

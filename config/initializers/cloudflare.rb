# frozen_string_literal: true

# 신뢰 프록시 설정 — 실제 클라이언트 IP 인식
#
# 요청 경로: 클라이언트 → Cloudflare → Fly.io → Thruster → Puma
#
# ActionDispatch::RemoteIp 는 X-Forwarded-For 를 뒤집은 뒤 신뢰 프록시를 걸러내고
# 남은 첫 번째 주소를 클라이언트 IP 로 판정한다. 따라서 중간 홉을 하나라도
# 빠뜨리면 그 홉의 주소가 클라이언트로 잡힌다.
#
# Fly 의 사설 대역(fdaa::/16)과 루프백은 Rails 기본 TRUSTED_PROXIES 의
# fc00::/7 · 127.0.0.0/8 에 이미 포함되지만, 공개 인그레스 주소는 아니다.

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

  # Fly.io 공개 인그레스 주소.
  # 이게 빠지면 remote_ip 가 Fly 주소로 고정되어, IP 단위 로그인 차단이
  # 사실상 전역 카운터 하나가 된다. 남의 실패 시도에 소유자가 잠긴다.
  #
  # 기본값은 `fly ips list` 기준이다. IPv4 는 shared 라 재할당될 수 있으므로
  # 바뀌면 FLY_INGRESS_IPS 환경변수로 덮어쓴다.
  FLY_INGRESS_IPS = ENV.fetch("FLY_INGRESS_IPS", "66.241.124.114/32,2a09:8280::/32")
                       .split(",").map(&:strip).reject(&:empty?).freeze

  Rails.application.config.action_dispatch.trusted_proxies =
    ActionDispatch::RemoteIp::TRUSTED_PROXIES +
    CLOUDFLARE_IPS.map { |ip| IPAddr.new(ip) } +
    CLOUDFLARE_IPV6.map { |ip| IPAddr.new(ip) } +
    FLY_INGRESS_IPS.map { |ip| IPAddr.new(ip) }
end

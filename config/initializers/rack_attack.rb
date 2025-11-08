# frozen_string_literal: true

# Rack Attack 설정
# https://github.com/rack/rack-attack

class Rack::Attack
  ### Configure Cache ###
  # Redis를 사용하지 않으면 기본 메모리 스토어 사용
  # 프로덕션에서는 Redis 사용 권장
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  ### Throttle Configuration ###

  # Magic Link & OTP 요청 제한
  # 동일 IP에서 5분당 최대 5회 요청
  throttle("magic_link/ip", limit: 5, period: 5.minutes) do |req|
    if req.path == "/signin" && req.post?
      req.ip
    end
  end

  # OTP 검증 제한
  # 동일 IP에서 5분당 최대 10회 시도
  throttle("otp_verify/ip", limit: 10, period: 5.minutes) do |req|
    if req.path == "/members/api/verify-otp" && req.post?
      req.ip
    end
  end

  # 회원가입 제한
  # 동일 IP에서 1시간당 최대 3회 회원가입
  throttle("signup/ip", limit: 3, period: 1.hour) do |req|
    if req.path == "/signup" && req.post?
      req.ip
    end
  end

  # API 엔드포인트 전반적인 제한
  # 동일 IP에서 1분당 최대 60회 요청
  throttle("api/ip", limit: 60, period: 1.minute) do |req|
    if req.path.start_with?("/members/api/")
      req.ip
    end
  end

  # 검색 API 제한
  # 동일 IP에서 1분당 최대 20회 검색
  throttle("search/ip", limit: 20, period: 1.minute) do |req|
    if req.path == "/search"
      req.ip
    end
  end

  ### Custom Throttle Response ###
  # Rate limit 초과 시 응답 커스터마이징
  self.throttled_responder = lambda do |request|
    match_data = request.env["rack.attack.match_data"]
    now = match_data[:epoch_time]

    headers = {
      "RateLimit-Limit" => match_data[:limit].to_s,
      "RateLimit-Remaining" => "0",
      "RateLimit-Reset" => (now + (match_data[:period] - (now % match_data[:period]))).to_s,
      "Content-Type" => "application/json"
    }

    body = {
      error: "Rate limit exceeded. Please try again later.",
      retry_after: match_data[:period]
    }.to_json

    [ 429, headers, [ body ] ]
  end

  ### Blocklist & Safelist ###
  # 특정 IP를 영구적으로 차단하거나 허용할 수 있습니다

  # Safelist: 항상 허용할 IP (예: 관리자 IP)
  # safelist("allow-localhost") do |req|
  #   req.ip == "127.0.0.1" || req.ip == "::1"
  # end

  # Blocklist: 항상 차단할 IP
  # blocklist("block-bad-actors") do |req|
  #   # 차단할 IP 목록 (데이터베이스에서 관리 권장)
  #   # BlockedIp.where(ip_address: req.ip).exists?
  # end

  ### Exponential Backoff ###
  # 반복적인 실패 시도에 대한 지수적 백오프
  # blocklist("fail2ban/pentesters") do |req|
  #   Rack::Attack::Fail2Ban.filter("pentesters-#{req.ip}", maxretry: 5, findtime: 10.minutes, bantime: 1.hour) do
  #     CGI.unescape(req.query_string) =~ /php|exe|sql|union|select/i
  #   end
  # end

  ### Logging ###
  # Rate limit 이벤트 로깅
  ActiveSupport::Notifications.subscribe("throttle.rack_attack") do |_name, _start, _finish, _request_id, payload|
    req = payload[:request]
    Rails.logger.warn "[Rack::Attack] Throttled request: #{req.ip} - #{req.path} - #{req.user_agent}"
  end

  ActiveSupport::Notifications.subscribe("blocklist.rack_attack") do |_name, _start, _finish, _request_id, payload|
    req = payload[:request]
    Rails.logger.warn "[Rack::Attack] Blocked request: #{req.ip} - #{req.path}"
  end
end

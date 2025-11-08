# frozen_string_literal: true

module Members
  module Api
    class IntegrityTokenController < ApplicationController
      # GET /members/api/integrity-token
      # IntegrityToken 생성 및 반환
      def show
        # IntegrityToken 형식: "13자(랜덤숫자):32자(랜덤문자):64자(랜덤문자)"
        integrity_token = generate_integrity_token

        # 세션에 저장 (검증용)
        session[:integrity_token] = integrity_token
        session[:integrity_token_created_at] = Time.current.to_i

        render json: {
          integrityToken: integrity_token
        }, status: :ok
      end

      private

      def generate_integrity_token
        # 13자리 랜덤 숫자 (타임스탬프 기반)
        timestamp = (Time.current.to_f * 1000).to_i.to_s

        # 32자 랜덤 문자 (16진수)
        random_32 = SecureRandom.hex(16)

        # 64자 랜덤 문자 (16진수)
        random_64 = SecureRandom.hex(32)

        "#{timestamp}:#{random_32}:#{random_64}"
      end
    end
  end
end

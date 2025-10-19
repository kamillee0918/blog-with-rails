# TODO: 회원가입 및 로그인, 마이페이지 로직 구현 (Phase 4에서 구현)
class AuthorizationController < ApplicationController
  def index
    respond_to do |format|
      format.html # 일반 HTML 응답
      format.json # JSON 응답
    end
  end
end

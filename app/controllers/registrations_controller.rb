# 회원가입 관련 컨트롤러
# Magic Link 인증 후에만 회원가입 완료
class RegistrationsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.verified = false

    if @user.save
      # Magic Link 생성 및 발송 (Service 사용)
      service = Authentication::MagicLinkService.new(@user)
      if service.generate_and_send(include_otp: false)
        render json: {
          success: true,
          message: "Magic Link를 이메일로 전송했습니다. 링크를 확인해주세요.",
          email: @user.email
        }, status: :created
      else
        render json: {
          success: false,
          message: "Magic Link 전송에 실패했습니다.",
          errors: service.errors
        }, status: :unprocessable_entity
      end
    else
      render json: {
        success: false,
        message: "회원가입에 실패했습니다.",
        errors: @user.errors.full_messages
      }, status: :bad_request
    end
  end

  private
    def user_params
      params.require(:user).permit(:nickname, :email)
    end
end

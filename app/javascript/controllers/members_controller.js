import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="members"
export default class extends Controller {
  static targets = [
    "form",
    "input",
    "button",
    "textSpan",
    "spinner",
    "checkmark",
    "error"
  ]

  connect() {
    console.log("Members controller connected")
  }

  async subscribe(event) {
    event.preventDefault()

    const email = this.inputTarget.value.trim()

    if (!email) {
      return
    }

    console.log("Members subscription attempt:", { email })

    // 버튼 비활성화
    this.buttonTarget.disabled = true

    try {
      // 1단계: Subscribe 텍스트 숨김, Spinner 표시
      this.showSpinner()

      // 1.5초 대기 (로딩 시뮬레이션)
      await this.wait(1500)

      // 의도적으로 오류 메시지 발생 및 확인
      // this.showError()

      // 2단계: Spinner 숨김, Checkmark 표시
      this.showCheckmark()

      // 1.5초 대기 (체크마크 애니메이션)
      await this.wait(1500)

      // 3단계: Alert 표시
      alert(`Members 구독 요청:\nEmail: ${email}\n\n(실제 구현은 Phase 4에서 진행됩니다)`)

    } catch (error) {
      console.error("Members subscription error:", error)
    }
  }

  showSpinner() {
    // form 태그에 loading 클래스 토글
    this.formTarget.classList.toggle("loading")
  }

  showCheckmark() {
    // form 태그에 success 클래스 토글
    this.formTarget.classList.remove("loading")
    this.formTarget.classList.toggle("success")
  }

  showError() {
    this.formTarget.classList.remove("loading")
    this.formTarget.classList.toggle("error")

    // p 태그에 error 메시지 표시(임시로 magic link 인증 실패 메시지 추가)
    this.errorTarget.textContent = "Failed to send magic link email"

    // TODO: 여러 번(5번) 인증 요청 시 아래의 메시지 표시
    // Too many sign-up attempts, try again later
  }

  // Promise 기반 대기 함수
  wait(ms) {
    return new Promise(resolve => setTimeout(resolve, ms))
  }
}

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="burger"
export default class extends Controller {
  connect() {
    console.log("🍔 Burger controller connected")

    // header 요소 참조 저장
    this.headerElement = document.getElementById("gh-navigation")
    this.htmlElement = document.documentElement

    // 미디어 쿼리 설정 (767px 이하: 모바일)
    this.mobileQuery = window.matchMedia("(max-width: 767px)")

    // 미디어 쿼리 변경 이벤트 리스너 추가
    this.handleMediaChange = this.handleMediaChange.bind(this)
    this.mobileQuery.addEventListener("change", this.handleMediaChange)

    // 초기 상태 확인
    this.handleMediaChange(this.mobileQuery)
  }

  disconnect() {
    // 이벤트 리스너 정리
    if (this.mobileQuery) {
      this.mobileQuery.removeEventListener("change", this.handleMediaChange)
    }
  }

  toggleMenu(event) {
    event.preventDefault()

    console.log("🍔 Burger menu toggle")

    // header에 is-open 클래스 토글
    if (this.headerElement) {
      this.headerElement.classList.toggle("is-open")

      // is-open 상태에 따라 html 스타일 조절
      if (this.headerElement.classList.contains("is-open")) {
        // 메뉴 열림: 스크롤 방지
        this.htmlElement.style.overflowY = "hidden"
        console.log("✅ Menu opened")
      } else {
        // 메뉴 닫힘: 스크롤 복원
        this.htmlElement.style.overflowY = ""
        console.log("❌ Menu closed")
      }
    }
  }

  handleMediaChange(event) {
    // 767px 초과 (데스크톱 레이아웃)
    if (!event.matches) {
      console.log("🖥️ Desktop layout: Closing mobile menu")
      this.closeMenu()
    }
  }

  closeMenu() {
    if (this.headerElement && this.headerElement.classList.contains("is-open")) {
      // is-open 클래스 제거
      this.headerElement.classList.remove("is-open")

      // html 스크롤 복원
      this.htmlElement.style.overflowY = ""

      console.log("❌ Menu closed (auto)")
    }
  }
}

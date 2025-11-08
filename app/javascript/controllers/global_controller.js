import { Controller } from "@hotwired/stimulus";

// 전역 Global 컨트롤러
// 모든 페이지에서 사용 가능
export default class extends Controller {
  connect() {
    console.log("🔔 Global controller connected");
    console.log("📍 Targets:", {
      notification: this.hasNotificationTarget,
      notificationText: this.hasNotificationTextTarget,
      notificationCloseIcon: this.hasNotificationCloseIconTarget,
    });

    // 사용자 정보 캐시 초기화
    this.cachedUserData = null;

    // 페이지 로드 시 사용자 정보 가져오기
    this.fetchUserData();

    // 페이지 로드 시 URL 파라미터 확인
    this.checkUrlParams();

    // ===== Burger 요소 시작 =====
    // header 요소 참조 저장
    this.headerElement = document.getElementById("gh-navigation");
    this.htmlElement = document.documentElement;

    // 미디어 쿼리 설정 (767px 이하: 모바일)
    this.mobileQuery = window.matchMedia("(max-width: 767px)");

    // 미디어 쿼리 변경 이벤트 리스너 추가
    this.handleMediaChange = this.handleMediaChange.bind(this);
    this.mobileQuery.addEventListener("change", this.handleMediaChange);

    // 초기 상태 확인
    this.handleMediaChange(this.mobileQuery);
    // ===== Burger 요소 끝 =====
  }

  disconnect() {
    console.log("🔓 Global controller disconnected");

    // ===== Burger 요소 시작 =====
    // 이벤트 리스너 정리
    if (this.mobileQuery) {
      this.mobileQuery.removeEventListener("change", this.handleMediaChange);
    }
    // ===== Burger 요소 끝 =====

    // CSS 제거
    this.unloadCSS();
  }

  // [로컬] 메뉴(Burger) 토글
  toggleMenu(event) {
    event.preventDefault();

    console.log("🍔 Burger menu toggle");

    // header에 is-open 클래스 토글
    if (this.headerElement) {
      this.headerElement.classList.toggle("is-open");

      // is-open 상태에 따라 html 스타일 조절
      if (this.headerElement.classList.contains("is-open")) {
        // 메뉴 열림: 스크롤 방지
        this.htmlElement.style.overflowY = "hidden";
        console.log("✅ Menu opened");
      } else {
        // 메뉴 닫힘: 스크롤 복원
        this.htmlElement.style.overflowY = "";
        console.log("❌ Menu closed");
      }
    }
  }

  // [로컬] 미디어 쿼리 변경 이벤트 리스너
  handleMediaChange(event) {
    // 767px 초과 (데스크톱 레이아웃)
    if (!event.matches) {
      console.log("🖥️ Desktop layout: Closing mobile menu");
      this.closeMenu();
    }
  }

  // [로컬] 메뉴(Burger) 닫기
  closeMenu() {
    if (this.headerElement && this.headerElement.classList.contains("is-open")) {
      // is-open 클래스 제거
      this.headerElement.classList.remove("is-open");

      // html 스크롤 복원
      this.htmlElement.style.overflowY = "";

      console.log("❌ Menu closed (auto)");
    }
  }

  // [전역] 전용 CSS 로드
  loadCSS() {
    // 이미 로드되어 있는지 확인
    if (document.getElementById("global-css")) {
      console.log("✅ Global CSS already loaded");
      return;
    }

    console.log("📦 Loading global CSS...");

    const style = document.createElement("style");
    style.id = "global-css";
    style.textContent = `
      /* Notification CSS - Minimal styles for toast notifications */
      :root {
        --black: #000;
        --blackrgb: 0,0,0;
        --grey0: #1d1d1d;
        --grey1: #333;
        --grey1rgb: 33, 33, 33;
        --grey2: #3d3d3d;
        --grey3: #474747;
        --grey4: #515151;
        --grey5: #686868;
        --grey6: #7f7f7f;
        --grey7: #979797;
        --grey8: #aeaeae;
        --grey9: #c5c5c5;
        --grey10: #dcdcdc;
        --grey11: #e1e1e1;
        --grey12: #eaeaea;
        --grey13: #f9f9f9;
        --grey13rgb: 249,249,249;
        --grey14: #fbfbfb;
        --white: #fff;
        --whitergb: 255,255,255;
        --red: #f02525;
        --darkerRed: #C50202;
        --yellow: #FFDC15;
        --green: #30CF43;
      }

      svg {
        box-sizing: content-box;
      }

      *, ::after, ::before {
        box-sizing: border-box;
      }

      .gh-portal-notification-wrapper {
        position: relative;
        overflow: hidden;
        height: 100%;
        width: 100%;
      }

      .gh-portal-notification {
        position: absolute;
        display: flex;
        gap: 12px;
        align-items: flex-start;
        top: 12px;
        right: 12px;
        width: 100%;
        padding: 16px;
        max-width: 380px;
        font-size: 1.3rem;
        line-height: 1.6em;
        font-weight: 400;
        font-style: normal;
        letter-spacing: 0.2px;
        background: var(--white);
        backdrop-filter: blur(8px);
        color: var(--grey0);
        border-radius: 7px;
        box-shadow: 0px 0px 1px 0px rgba(0, 0, 0, 0.30), 0px 51px 40px 0px rgba(0, 0, 0, 0.05), 0px 15.375px 12.059px 0px rgba(0, 0, 0, 0.03), 0px 6.386px 5.009px 0px rgba(0, 0, 0, 0.03), 0px 2.31px 1.812px 0px rgba(0, 0, 0, 0.02);
        animation: notification-slidein 0.55s cubic-bezier(0.215, 0.610, 0.355, 1.000);
        z-index: 99999;
      }

      html[dir="rtl"] .gh-portal-notification {
        right: unset;
        left: 12px;
        padding: 14px 20px 18px 44px;
      }

      .gh-portal-notification.slideout {
        animation: notification-slideout 0.4s cubic-bezier(0.550, 0.055, 0.675, 0.190);
      }

      .gh-portal-notification.hide {
        display: none;
      }

      .gh-portal-notification p {
        flex-grow: 1;
        font-size: 1.4rem;
        line-height: 1.5em;
        text-align: start;
        margin: 0;
        padding: 0;
        color: var(--grey0);
      }

      .gh-portal-notification p strong {
        color: var(--grey0);
      }

      .gh-portal-notification a {
        color: var(--grey0);
        text-decoration: underline;
        transition: all 0.2s ease-in-out;
        outline: none;
      }

      .gh-portal-notification a:hover {
        opacity: 0.8;
      }

      .gh-portal-notification-icon {
        width: 18px;
        height: 18px;
        min-width: 18px;
        margin-top: 2px;
      }

      html[dir="rtl"] .gh-portal-notification-icon {
        right: 17px;
        left: unset;
      }

      .gh-portal-notification-icon.success {
        color: var(--green);
      }

      .gh-portal-notification-icon.error {
        color: var(--red);
      }

      .gh-portal-notification-closeicon {
        color: var(--grey8);
        cursor: pointer;
        width: 12px;
        min-width: 12px;
        height: 12px;
        padding: 10px;
        margin-top: -6px;
        margin-right: -6px;
        margin-bottom: -6px;
        transition: all 0.2s ease-in-out forwards;
        opacity: 0.8;
      }

      .gh-portal-notification-closeicon:hover {
        opacity: 1.0;
      }

      @keyframes notification-slidein {
        0% {
          transform: translateX(380px);
        }

        60% {
          transform: translateX(-6px);
        }

        100% {
          transform: translateX(0);
        }
      }

      @keyframes notification-slideout {
        0% {
          transform: translateX(0);
        }

        30% {
          transform: translateX(-10px);
        }

        100% {
          transform: translateX(380px);
        }
      }

      @keyframes notification-slidein-mobile {
        0% {
          transform: translateY(-150px);
        }

        50% {
          transform: translateY(6px);
        }

        100% {
          transform: translateY(0);
        }
      }

      @keyframes notification-slideout-mobile {
        0% {
          transform: translateY(0);
        }

        35% {
          transform: translateY(6px);
        }

        100% {
          transform: translateY(-150px);
        }
      }

      @media (max-width: 480px) {
        .gh-portal-notification {
          left: 12px;
          max-width: calc(100% - 24px);
          animation-name: notification-slidein-mobile;
        }

        html[dir="rtl"] .gh-portal-notification {
          right: 12px;
          left: unset;
        }

        .gh-portal-notification.slideout {
          animation-duration: 0.55s;
          animation-name: notification-slideout-mobile;
        }
      }

      .gh-portal-popupnotification {
        right: 42px;
      }

      html[dir="rtl"] .gh-portal-notification {
        right: unset;
        left: 42px;
      }

      @media (max-width: 480px) {
        .gh-portal-notification {
          max-width: calc(100% - 54px);
        }
      }

      /* Button Loading */
      .gh-portal-loadingicon {
        width: 20px !important;
        height: 20px !important;
        margin-left: 8px;
        vertical-align: middle;
      }

      .gh-portal-loadingicon {
        position: absolute;
        left: 50%;
        display: inline-block;
        margin-inline-start: -19px;
        height: 31px;
      }

      .gh-portal-loadingicon path,
      .gh-portal-loadingicon rect {
        fill: var(--white);
      }

      .gh-portal-loadingicon.dark path,
      .gh-portal-loadingicon.dark rect {
        fill: var(--grey0);
      }
    `;

    document.head.appendChild(style);
    console.log("✅ Global CSS loaded successfully");
  }

  // [전역 ]CSS 제거
  unloadCSS() {
    const style = document.getElementById("global-css");
    if (style) {
      console.log("🗑️ Unloading Global CSS...");
      style.remove();
      console.log("✅ Global CSS unloaded");
    }
  }

  // URL 파라미터 확인
  async checkUrlParams() {
    try {
      const urlParams = new URLSearchParams(window.location.search);
      const action = urlParams.get("action");
      const success = urlParams.get("success");
      const expired = urlParams.get("expired");

      console.log("🔍 Checking URL parameters:", { action, success, expired });

      // action=signin&success=true || action=signup&success=true: Magic Link 성공
      if ((action === "signin" || action === "signup") && success === "true") {
        console.log(`✅ Magic Link ${action} success detected`);
        await this.handleAuthSuccess(action);
      }
      // action=signin&success=false || action=signup&success=false: Magic Link 만료
      else if ((action === "signin" || action === "signup") && success === "false") {
        console.log("⚠️ Magic Link expired");
        console.log("⚠️ Magic Link expired action: ", action);
        this.handleExpiredMagicLink(action);
      }
      // action=account&expired=true: 로그인된 상태에서 만료된 링크 클릭
      else if (action === "account" && expired === "true") {
        console.log("⚠️ Expired link clicked while logged in");
        this.handleExpiredWhileLoggedIn();
      }
    } catch (error) {
      console.error("❌ Error checking URL params:", error);
    }
  }

  // Magic Link 인증 성공 처리 (로그인/회원가입)
  async handleAuthSuccess(action) {
    try {
      // fetchUserData()가 이미 호출되었으므로 캐시된 데이터를 사용하되,
      // 없으면 짧은 시간 대기 후 재확인 (fetchUserData 완료 대기)
      let userData = this.cachedUserData;

      if (!userData) {
        console.log("⏳ Waiting for user data...");
        // 최대 3초 대기 (100ms 간격으로 체크)
        for (let i = 0; i < 30; i++) {
          await new Promise(resolve => setTimeout(resolve, 100));
          if (this.cachedUserData) {
            userData = this.cachedUserData;
            break;
          }
        }
      }

      if (userData) {
        const userNickname = userData.name || "User";
        console.log("👤 User data from Magic Link:", userData);

        // 회원가입/로그인에 따라 다른 메시지 표시
        const message =
          action === "signup" ? "Welcome! You've successfully signed up." : "You've successfully signed in.";

        this.showNotification(message, "success", userNickname);

        // 3초 후 URL에서 쿼리 파라미터 제거
        setTimeout(() => {
          window.history.replaceState({}, document.title, "/");
          console.log("🔄 URL cleaned: / (query params removed)");
        }, 3000);
      } else {
        console.error("❌ Failed to get user data after Magic Link");
      }
    } catch (error) {
      console.error("❌ Error handling auth success:", error);
    }
  }

  // Magic Link 만료 처리 (로그인 혹은 회원가입 실패 상태)
  handleExpiredMagicLink(action) {
    if (action === "signin") {
      // 클릭 가능한 notification 표시
      this.showClickableNotification(
        "Could not sign in. Signin link expired.<br><a href='/#/signin' target='_parent'>Click here to retry</a>",
        "signin",
        "error",
      );
    } else if (action === "signup") {
      // 클릭 가능한 notification 표시
      this.showClickableNotification(
        "Could not sign up. Signup link expired.<br><a href='/#/signup' target='_parent'>Click here to retry</a>",
        "signup",
        "error",
      );
    }
    // URL에서 쿼리 파라미터 제거
    setTimeout(() => {
      window.history.replaceState({}, document.title, "/");
    }, 3000);
  }

  // 로그인된 상태에서 만료된 링크 클릭
  handleExpiredWhileLoggedIn() {
    // 3초 후 URL에서 쿼리 파라미터 제거
    setTimeout(() => {
      // 회원정보 모달 열기
      window.dispatchEvent(new CustomEvent("account:open"));
      // URL에서 쿼리 파라미터 제거
      window.history.replaceState({}, document.title, "/");
    }, 3000);
  }

  // [전역] 키보드 단축키 처리 (Escape)
  // 다른 컨트롤러에서 호출할 때 콜백 함수를 전달받아 실행
  handleKeyboard(event, options = {}) {
    const { onEscape, condition } = options;

    // condition이 있으면 확인 (예: 모달이 열려있는지)
    if (condition && !condition()) {
      return;
    }

    // Escape 키 처리
    if (event.key === "Escape") {
      event.preventDefault();

      // onEscape 콜백이 있으면 실행
      if (onEscape && typeof onEscape === "function") {
        onEscape();
      }
    }
  }

  // [전역] 유효한 이메일 주소인지 검사
  isValidEmail(email) {
    const re = /^[a-zA-Z0-9]([a-zA-Z0-9._-]*[a-zA-Z0-9])?@[a-zA-Z0-9]([a-zA-Z0-9.-]*[a-zA-Z0-9])?\.([a-zA-Z]{2,6})$/;
    return !!email && re.test(String(email).toLowerCase());
  }

  // [전역] 에러 메시지 표시 (범용)
  // errorElement: 에러 메시지를 표시할 엘리먼트
  // inputElement: error 클래스를 추가할 input 엘리먼트 (선택)
  // message: 표시할 에러 메시지
  showError(errorElement, message, inputElement = null) {
    if (errorElement) {
      errorElement.textContent = message;
      errorElement.style.display = "block";
    }

    if (inputElement) {
      inputElement.classList.add("error");
    }
  }

  // [전역] 에러 메시지 숨기기 (범용)
  hideError(errorElement, inputElement = null) {
    if (errorElement) {
      errorElement.textContent = "";
      errorElement.style.display = "none";
    }

    if (inputElement) {
      inputElement.classList.remove("error");
    }
  }

  // [전역] notification 표시
  showNotification(message, type, nickname = null) {
    // CSS 로드
    this.loadCSS();

    // body에 notification 추가
    const body = document.body;

    // 기존 notification wrapper 제거
    const existingNotificationWrapper = body.querySelector(".gh-portal-notification-wrapper");
    if (existingNotificationWrapper) {
      existingNotificationWrapper.remove();
    }

    // notification wrapper 생성
    const notificationElement = document.createElement("div");
    notificationElement.className = "gh-portal-notification-wrapper";
    notificationElement.style = `
    z-index: 4000000; position: fixed; top: 0px; right: 0px; max-width: 481px; width: 100%; height: 220px; animation: 250ms animation-bhegco; transition: opacity 0.3s; overflow: hidden;
    `;
    body.appendChild(notificationElement);

    // notification container 생성
    const notificationContainer = document.createElement("div");
    notificationContainer.className = "gh-portal-notification";

    // type에 따라 스타일 및 내용 설정
    if (type === "success") {
      notificationContainer.classList.add("success");

      // nickname이 있으면 Welcome 메시지
      if (nickname) {
        notificationContainer.innerHTML = `
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="gh-portal-notification-icon success" alt="">
            <defs>
              <style>.checkmark-icon-fill{fill:currentColor;}</style>
            </defs>
            <path class="checkmark-icon-fill" d="M12,0A12,12,0,1,0,24,12,12.014,12.014,0,0,0,12,0Zm6.927,8.2-6.845,9.289a1.011,1.011,0,0,1-1.43.188L5.764,13.769a1,1,0,1,1,1.25-1.562l4.076,3.261,6.227-8.451A1,1,0,1,1,18.927,8.2Z"></path>
          </svg>
          <p>
            <strong>Welcome back, ${nickname}!</strong><br/>
            ${message}
          </p>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="gh-portal-notification-closeicon" alt="Close">
            <defs>
              <style>.a{fill:none;stroke:currentColor;stroke-linecap:round;stroke-linejoin:round;stroke-width:1.2px !important;}</style>
            </defs>
            <path class="a" d="M.75 23.249l22.5-22.5M23.25 23.249L.75.749"></path>
          </svg>
        `;
      } else {
        notificationContainer.innerHTML = `
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="gh-portal-notification-icon success" alt="">
            <defs>
              <style>.checkmark-icon-fill{fill:currentColor;}</style>
            </defs>
            <path class="checkmark-icon-fill" d="M12,0A12,12,0,1,0,24,12,12.014,12.014,0,0,0,12,0Zm6.927,8.2-6.845,9.289a1.011,1.011,0,0,1-1.43.188L5.764,13.769a1,1,0,1,1,1.25-1.562l4.076,3.261,6.227-8.451A1,1,0,1,1,18.927,8.2Z"></path>
          </svg>
          <p>${message}</p>
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="gh-portal-notification-closeicon" alt="Close">
            <defs>
              <style>.a{fill:none;stroke:currentColor;stroke-linecap:round;stroke-linejoin:round;stroke-width:1.2px !important;}</style>
            </defs>
            <path class="a" d="M.75 23.249l22.5-22.5M23.25 23.249L.75.749"></path>
          </svg>
        `;
      }
    } else if (type === "BadRequestError" || type === "error") {
      notificationContainer.classList.add("error");
      notificationContainer.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="gh-portal-notification-icon error" alt="">
          <defs>
            <style>.warning-icon-fill{fill:currentColor;}</style>
          </defs>
          <path class="warning-icon-fill" d="M23.25,23.235a.75.75,0,0,0,.661-1.105l-11.25-21a.782.782,0,0,0-1.322,0l-11.25,21A.75.75,0,0,0,.75,23.235ZM12,20.485a1.5,1.5,0,1,1,1.5-1.5A1.5,1.5,0,0,1,12,20.485Zm0-12.25a1,1,0,0,1,1,1V14.7a1,1,0,0,1-2,0V9.235A1,1,0,0,1,12,8.235Z"></path>
        </svg>
        <p>${message}</p>
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="gh-portal-notification-closeicon" alt="Close">
          <defs>
            <style>.a{fill:none;stroke:currentColor;stroke-linecap:round;stroke-linejoin:round;stroke-width:1.2px !important;}</style>
          </defs>
          <path class="a" d="M.75 23.249l22.5-22.5M23.25 23.249L.75.749"></path>
        </svg>
      `;
    }

    // 닫기 버튼 이벤트
    const closeIcon = notificationContainer.querySelector(".gh-portal-notification-closeicon");
    if (closeIcon) {
      closeIcon.addEventListener("click", e => {
        e.stopPropagation();
        notificationElement.remove();
        // CSS 제거
        this.unloadCSS();
        console.log("✅ Notification closed by user");
      });
    }

    // body 태그의 gh-portal-notification-wrapper 요소에 추가
    const wrapperElement = body.querySelector(".gh-portal-notification-wrapper");
    if (wrapperElement) {
      wrapperElement.insertBefore(notificationContainer, wrapperElement.firstChild);
      console.log(`⚠️ Notification displayed: ${message}`);
    } else {
      console.error("❌ .gh-portal-notification-wrapper not found - notification not displayed");
      // Fallback: body에 직접 추가
      body.appendChild(notificationContainer);
      console.log(`⚠️ Notification displayed (fallback): ${message}`);
    }

    // 3초 후 자동 제거 (주석 처리 - 사용자가 수동으로 닫도록)
    setTimeout(() => {
      if (notificationContainer.parentNode) {
        notificationElement.remove();
        this.unloadCSS();
        console.log("✅ Notification auto-removed after 3s");
      }
    }, 3000);
  }

  // [전역] 클릭 가능한 notification 표시 (HTML 링크 포함)
  showClickableNotification(htmlMessage, action, type = "error") {
    // CSS 로드
    this.loadCSS();

    // body에 notification 추가
    const body = document.body;

    // 기존 notification 제거
    const existingNotification = body.querySelector(".gh-portal-notification-wrapper");
    if (existingNotification) {
      existingNotification.remove();
    }

    // notification wrapper 생성
    const notificationElement = document.createElement("div");
    notificationElement.className = "gh-portal-notification-wrapper";
    notificationElement.style = `
    z-index: 4000000; position: fixed; top: 0px; right: 0px; max-width: 481px; width: 100%; height: 220px; animation: 250ms animation-bhegco; transition: opacity 0.3s; overflow: hidden;
    `;
    body.appendChild(notificationElement);

    // notification container 생성
    const notificationContainer = document.createElement("div");
    notificationContainer.className = "gh-portal-notification";

    if (type === "error") {
      notificationContainer.classList.add("error");
      notificationContainer.innerHTML = `
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="gh-portal-notification-icon error" alt="">
          <defs>
            <style>.warning-icon-fill{fill:currentColor;}</style>
          </defs>
          <path class="warning-icon-fill" d="M23.25,23.235a.75.75,0,0,0,.661-1.105l-11.25-21a.782.782,0,0,0-1.322,0l-11.25,21A.75.75,0,0,0,.75,23.235ZM12,20.485a1.5,1.5,0,1,1,1.5-1.5A1.5,1.5,0,0,1,12,20.485Zm0-12.25a1,1,0,0,1,1,1V14.7a1,1,0,0,1-2,0V9.235A1,1,0,0,1,12,8.235Z"></path>
        </svg>
        <p>${htmlMessage}</p>
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="gh-portal-notification-closeicon" alt="Close">
          <defs>
            <style>.a{fill:none;stroke:currentColor;stroke-linecap:round;stroke-linejoin:round;stroke-width:1.2px !important;}</style>
          </defs>
          <path class="a" d="M.75 23.249l22.5-22.5M23.25 23.249L.75.749"></path>
        </svg>
      `;
    }

    // 닫기 버튼 이벤트
    const closeIcon = notificationContainer.querySelector(".gh-portal-notification-closeicon");
    if (closeIcon) {
      closeIcon.addEventListener("click", e => {
        e.stopPropagation();
        notificationElement.remove();
        // CSS 제거
        this.unloadCSS();
        console.log("✅ Notification closed by user");
      });
    }

    // action에 따라 다른 링크 클릭 이벤트
    if (action === "signin") {
      const link = notificationContainer.querySelector("a");
      if (link) {
        link.addEventListener("click", e => {
          e.preventDefault();
          // notification 제거
          notificationElement.remove();
          this.unloadCSS();
          // 로그인 모달 열기
          window.dispatchEvent(
            new CustomEvent("authorization:open", {
              detail: { mode: "signin" },
              bubbles: true,
            }),
          );
          console.log("🔓 Opening signin modal from expired link");
        });
      }
    } else if (action === "signup") {
      const link = notificationContainer.querySelector("a");
      if (link) {
        link.addEventListener("click", e => {
          e.preventDefault();
          // notification 제거
          notificationElement.remove();
          this.unloadCSS();
          // 회원가입 모달 열기
          window.dispatchEvent(
            new CustomEvent("authorization:open", {
              detail: { mode: "signup" },
              bubbles: true,
            }),
          );
          console.log("🔓 Opening signup modal from expired link");
        });
      }
    }

    // body 태그의 gh-portal-notification-wrapper 요소에 추가
    const wrapperElement = body.querySelector(".gh-portal-notification-wrapper");
    if (wrapperElement) {
      wrapperElement.insertBefore(notificationContainer, wrapperElement.firstChild);
      console.log(`⚠️ Clickable notification displayed: ${htmlMessage}`);
    } else {
      console.error("❌ .gh-portal-notification-wrapper not found - notification not displayed");
      // Fallback: body에 직접 추가
      body.appendChild(notificationContainer);
      console.log(`⚠️ Clickable notification displayed (fallback): ${htmlMessage}`);
    }
  }

  // [전역] 버튼 내용 설정
  setButtonContent(button, isLoading, hasError) {
    if (isLoading) {
      // 로딩 상태: 버튼 비활성화 및 스타일 변경
      button.disabled = true;
      button.style.opacity = "0.5";
      button.style.pointerEvents = "none";

      // 기존 텍스트 저장
      if (!button.dataset.originalText) {
        button.dataset.originalText = button.innerHTML;
      }

      // 로딩 SVG로 대체
      button.innerHTML = `
        <svg id="loader-1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="40px" height="40px" viewBox="0 0 40 40" enable-background="new 0 0 40 40" xml:space="preserve" class="gh-portal-loadingicon">
          <path opacity="0.2" fill="#000" d="M20.201,5.169c-8.254,0-14.946,6.692-14.946,14.946c0,8.255,6.692,14.946,14.946,14.946 s14.946-6.691,14.946-14.946C35.146,11.861,28.455,5.169,20.201,5.169z M20.201,31.749c-6.425,0-11.634-5.208-11.634-11.634 c0-6.425,5.209-11.634,11.634-11.634c6.425,0,11.633,5.209,11.633,11.634C31.834,26.541,26.626,31.749,20.201,31.749z"></path>
          <path fill="#000" d="M26.013,10.047l1.654-2.866c-2.198-1.272-4.743-2.012-7.466-2.012h0v3.312h0 C22.32,8.481,24.301,9.057,26.013,10.047z">
            <animateTransform attributeType="xml" attributeName="transform" type="rotate" from="0 20 20" to="360 20 20" dur="0.5s" repeatCount="indefinite"></animateTransform>
          </path>
        </svg>
        `;
    } else {
      // 로딩 해제: 버튼 활성화 및 스타일 복원
      button.disabled = false;
      button.style.opacity = "1";
      button.style.pointerEvents = "auto";

      // 원래 텍스트 복원
      if (button.dataset.originalText) {
        button.innerHTML = button.dataset.originalText;
        console.log("✅ Button text restored to original: ", button.innerHTML);
      }
    }

    if (hasError) {
      // 오류 발생 시, 버튼 텍스트를 "Retry"로 변경
      button.innerHTML = "Retry";
      console.log("✅ Button text changed to Retry: ", button.innerHTML);
    }
  }

  // [전역] CSRF 토큰 가져오기
  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]');
    return token ? token.content : "";
  }

  // [전역] 사용자 정보 가져오기 및 캐시
  async fetchUserData() {
    try {
      console.log("📡 Global - Fetching user data on page load...");
      const response = await fetch("/members/api/member", {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.getCSRFToken(),
        },
      });

      // 204 No Content는 response.ok가 true이므로 먼저 체크
      if (response.status === 204) {
        this.cachedUserData = null;
        console.log("ℹ️ Global - No user session (204 No Content)");
      } else if (response.ok) {
        const data = await response.json();
        this.cachedUserData = data;
        console.log("✅ Global - User data cached:", data);
      } else {
        console.error("❌ Global - Failed to fetch user data:", response.status);
        this.cachedUserData = null;
      }
    } catch (error) {
      console.error("❌ Global - Error fetching user data:", error);
      this.cachedUserData = null;
    }
  }

  // [전역] 캐시된 사용자 정보 가져오기
  getCachedUserData() {
    console.log("Global - getCachedUserData called...");
    return this.cachedUserData;
  }

  // [전역] 사용자 정보 캐시 갱신
  async refreshUserData() {
    console.log("Global - refreshUserData called...");
    await this.fetchUserData();
    console.log("✅ Global - User data refreshed:", this.cachedUserData);
    return this.cachedUserData;
  }

  // [전역] 검색 모달 열기
  openSearch(event) {
    event.preventDefault();
    window.dispatchEvent(new CustomEvent("search:open", { bubbles: true }));
  }

  // [전역] 로그인 모달 열기
  openSignin(event) {
    event.preventDefault();
    window.dispatchEvent(
      new CustomEvent("authorization:open", {
        detail: { mode: "signin" },
        bubbles: true,
      }),
    );
  }

  // [전역] 회원가입 모달 열기
  openSignup(event) {
    event.preventDefault();
    window.dispatchEvent(
      new CustomEvent("authorization:open", {
        detail: { mode: "signup" },
        bubbles: true,
      }),
    );
  }

  // [전역] 계정 모달 열기
  openAccount(event) {
    event.preventDefault();
    window.dispatchEvent(
      new CustomEvent("account:open", {
        detail: { mode: "account" },
        bubbles: true,
      }),
    );
  }
}

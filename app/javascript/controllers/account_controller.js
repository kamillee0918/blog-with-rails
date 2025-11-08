import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="account"
export default class extends Controller {
  static targets = [
    "wrapper",
    "container",
    "overlay",
    "notification",
    "input",
    "editNickname",
    "editEmail",
    "editNicknameError",
    "editEmailError",
    "errorMessage",
    "errorNicknameMessage",
    "errorEmailMessage",
    "homeModal",
    "editModal",
    "manageModal",
    "backToHomeButton",
    "editProfileButton",
    "manageSubscriptionButton",
    "editProfileSubmitButton",
    "logout",
  ];

  connect() {
    console.log("🔐 Account controller connected");
    console.log("📍 Targets:", {
      wrapper: this.hasWrapperTarget,
      container: this.hasContainerTarget,
      overlay: this.hasOverlayTarget,
      notification: this.hasNotificationTarget,
      input: this.hasInputTarget,
      editNickname: this.hasEditNicknameTarget,
      editEmail: this.hasEditEmailTarget,
      editNicknameError: this.hasEditNicknameErrorTarget,
      editEmailError: this.hasEditEmailErrorTarget,
      errorMessage: this.hasErrorMessageTarget,
      errorNicknameMessage: this.hasErrorNicknameMessageTarget,
      errorEmailMessage: this.hasErrorEmailMessageTarget,
      homeModal: this.hasHomeModalTarget,
      editModal: this.hasEditModalTarget,
      manageModal: this.hasManageModalTarget,
      backToHomeButton: this.hasBackToHomeButtonTarget,
      editProfileButton: this.hasEditProfileButtonTarget,
      manageSubscriptionButton: this.hasManageSubscriptionButtonTarget,
      editProfileSubmitButton: this.hasEditProfileSubmitButtonTarget,
      logout: this.hasLogoutTarget,
    });

    // #account-root 요소 참조 저장
    this.rootElement = document.getElementById("account-root");

    // 초기 상태: 계정 정보 화면 표시
    this.currentMode = "home";

    // Submit 진행 중 플래그 (요청 중에는 모달이 닫히지 않도록)
    this.isSubmitting = false;

    // 원본 사용자 정보 저장 (변경 사항 비교용)
    this.originalUserData = null;

    // 현재 사용자 데이터 캐시
    this.currentUserData = null;
  }

  disconnect() {
    console.log("🔓 Account controller disconnected");

    // 모달 CSS 제거
    this.unloadModalCSS();
  }

  // 모달 전용 CSS 로드
  loadModalCSS() {
    // 이미 로드되어 있는지 확인
    if (document.getElementById("account-modal-css")) {
      console.log("✅ Account Modal CSS already loaded");
      return;
    }

    console.log("📦 Loading account modal CSS...");

    const style = document.createElement("style");
    style.id = "account-modal-css";
    style.textContent = `
      /* Globals
      /* ----------------------------------------------------- */
      body {
        margin: 0px;
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, Cantarell, "Open Sans", "Helvetica Neue", sans-serif;
        font-size: 1.6rem;
        height: 100%;
        line-height: 1.6em;
        font-weight: 400;
        font-style: normal;
        color: var(--grey2);
        box-sizing: border-box;
        overflow: hidden;
      }

      button,
      button span {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, Cantarell, "Open Sans", "Helvetica Neue", sans-serif;
      }

      *,
      ::after,
      ::before {
        box-sizing: border-box;
      }

      h1,
      h2,
      h3,
      h4,
      h5,
      h6,
      p {
        line-height: 1.15em;
        padding: 0;
        margin: 0;
      }

      h1 {
        font-size: 35px;
        font-weight: 700;
        letter-spacing: -0.022em;
      }

      h2 {
        font-size: 32px;
        font-weight: 700;
        letter-spacing: -0.021em;
      }

      h3 {
        font-size: 24px;
        font-weight: 700;
        letter-spacing: -0.019em;
      }

      h4 {
        font-size: 19px;
        font-weight: 700;
        letter-spacing: -0.02em;
      }

      h5 {
        font-size: 15px;
        font-weight: 700;
        letter-spacing: -0.02em;
      }

      p {
        font-size: 15px;
        line-height: 1.5em;
        margin-bottom: 24px;
      }

      strong {
        font-weight: 600;
      }

      a,
      .gh-portal-link {
        cursor: pointer;
      }

      p a {
        font-weight: 500;
        color: var(--brand-color);
        text-decoration: none;
      }

      svg {
        box-sizing: content-box;
      }

      input,
      textarea {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, Cantarell, "Open Sans", "Helvetica Neue", sans-serif;
        font-size: 1.5rem;
      }

      @media (max-width: 1440px) {
        h1 {
          font-size: 32px;
          letter-spacing: -0.022em;
        }

        h2 {
          font-size: 28px;
          letter-spacing: -0.021em;
        }

        h3 {
          font-size: 26px;
          letter-spacing: -0.02em;
        }
      }

      @media (max-width: 480px) {
        h1 {
          font-size: 30px;
          letter-spacing: -0.021em;
        }

        h2 {
          font-size: 26px;
          letter-spacing: -0.02em;
        }

        h3 {
          font-size: 24px;
          letter-spacing: -0.019em;
        }
      }

      .gh-portal-main-title {
        text-align: center;
        color: var(--grey0);
        line-height: 1.1em;
      }

      .gh-portal-text-disabled {
        color: var(--grey3);
        font-weight: normal;
        opacity: 0.35;
      }

      .gh-portal-text-center {
        text-align: center;
      }

      .gh-portal-input-label {
        color: var(--grey1);
        font-size: 1.3rem;
        font-weight: 600;
        margin-bottom: 2px;
        letter-spacing: 0px;
      }

      .gh-portal-error {
        color: var(--red);
        font-size: 1.4rem;
        line-height: 1.6em;
        margin: 12px 0;
      }

      /* Buttons
      /* ----------------------------------------------------- */
      .gh-portal-btn {
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.5rem;
        font-weight: 500;
        line-height: 1em;
        letter-spacing: 0.2px;
        text-align: center;
        white-space: nowrap;
        text-decoration: none;
        color: var(--brand-color);
        background: var(--white);
        border: 1px solid var(--grey12);
        min-width: 80px;
        height: 44px;
        padding: 0 1.8rem;
        border-radius: 6px;
        cursor: pointer;
        transition: all .25s ease;
        box-shadow: none;
        user-select: none;
        outline: none;
      }

      .gh-portal-btn:hover {
        border-color: var(--grey10);
      }

      .gh-portal-btn:disabled {
        opacity: 0.5 !important;
        cursor: auto;
      }

      .gh-portal-btn-container.sticky {
        transition: none;
        position: sticky;
        bottom: 0;
        margin: 0 0 -32px;
        padding: 32px 0 32px;
        background: linear-gradient(0deg, rgba(var(--whitergb), 1) 75%, rgba(var(--whitergb), 0) 100%);
      }

      .gh-portal-btn-container.sticky.m28 {
        margin: 0 0 -28px;
        padding: 28px 0 28px;
      }

      .gh-portal-btn-container.sticky.m24 {
        margin: 0 0 -24px;
        padding: 24px 0 24px;
      }

      .gh-portal-signup-terms-wrapper+.gh-portal-btn-container {
        margin: 16px 0 0;
      }

      .gh-portal-signup-terms-wrapper+.gh-portal-btn-container.sticky.m24 {
        padding: 16px 0 24px;
      }

      .gh-portal-btn-container .gh-portal-btn {
        margin: 0;
      }

      .gh-portal-btn-icon svg {
        width: 16px;
        height: 16px;
        margin-inline-end: 4px;
        stroke: currentColor;
      }

      .gh-portal-btn-icon svg path {
        stroke: currentColor;
      }

      .gh-portal-btn-link {
        line-height: 1;
        background: none;
        padding: 0;
        height: unset;
        min-width: unset;
        box-shadow: none;
        border: none;
      }

      .gh-portal-btn-link:hover {
        box-shadow: none;
        opacity: 0.85;
      }

      .gh-portal-btn-branded {
        color: var(--brand-color);
      }

      .gh-portal-btn-list {
        font-size: 1.5rem;
        color: var(--brand-color);
        height: 38px;
        width: unset;
        min-width: unset;
        padding: 0 4px;
        margin: 0 -4px;
        box-shadow: none;
        border: none;
      }

      .gh-portal-btn-list:hover {
        box-shadow: none;
        opacity: 0.75;
      }

      .gh-portal-btn-logout {
        position: absolute;
        top: 22px;
        left: 24px;
        background: none;
        border: none;
        height: unset;
        color: var(--grey3);
        padding: 0;
        margin: 0;
        z-index: 999;
        box-shadow: none;
      }

      .gh-portal-btn-logout .label {
        opacity: 0;
        transform: translateX(-6px);
        transition: all 0.2s ease-in-out;
      }

      .gh-portal-btn-logout:hover {
        padding: 0;
        margin: 0;
        background: none;
        border: none;
        height: unset;
        box-shadow: none;
      }

      .gh-portal-btn-logout:hover .label {
        opacity: 1.0;
        transform: translateX(-4px);
      }

      /* Global layout styles
      /* ----------------------------------------------------- */
      .gh-portal-popup-background {
        position: absolute;
        display: block;
        top: 0;
        right: 0;
        bottom: 0;
        left: 0;
        animation: fadein 0.2s;
        background: linear-gradient(315deg, rgba(var(--blackrgb), 0.2) 0%, rgba(var(--blackrgb), 0.1) 100%);
        backdrop-filter: blur(2px);
        -webkit-backdrop-filter: blur(2px);
        -webkit-transform: translate3d(0, 0, 0);
        -moz-transform: translate3d(0, 0, 0);
        -ms-transform: translate3d(0, 0, 0);
        transform: translate3d(0, 0, 0);
      }

      .gh-portal-popup-background.preview {
        background: linear-gradient(45deg, rgba(255, 255, 255, 1) 0%, rgba(249, 249, 250, 1) 100%);
        animation: none;
        pointer-events: none;
      }

      @keyframes fadein {
        0% {
          opacity: 0;
        }

        100% {
          opacity: 1.0;
        }
      }

      .gh-portal-popup-wrapper {
        position: relative;
        padding: 5vmin 0 0;
        height: 100%;
        max-height: 100vh;
        overflow: scroll;
      }

      /* Hiding scrollbars */
      .gh-portal-popup-wrapper {
        padding-inline-end: 30px !important;
        margin-inline-end: -30px !important;
        -ms-overflow-style: none;
        scrollbar-width: none;
      }

      .gh-portal-popup-wrapper::-webkit-scrollbar {
        display: none;
      }

      .gh-portal-popup-wrapper.full-size {
        height: 100vh;
        padding: 0;
      }

      .gh-portal-popup-container {
        outline: none;
        position: relative;
        display: flex;
        box-sizing: border-box;
        flex-direction: column;
        justify-content: flex-start;
        font-size: 1.5rem;
        text-align: start;
        letter-spacing: 0;
        text-rendering: optimizeLegibility;
        background: var(--white);
        width: 500px;
        margin: 0 auto 40px;
        padding: 32px;
        transform: translateY(0px);
        border-radius: 10px;
        box-shadow: 0 3.8px 2.2px rgba(var(--blackrgb), 0.028), 0 9.2px 5.3px rgba(var(--blackrgb), 0.04), 0 17.3px 10px rgba(var(--blackrgb), 0.05), 0 30.8px 17.9px rgba(var(--blackrgb), 0.06), 0 57.7px 33.4px rgba(var(--blackrgb), 0.072), 0 138px 80px rgba(var(--blackrgb), 0.1);
        animation: popup 0.25s ease-in-out;
        z-index: 9999;
      }

      .gh-portal-popup-container.large-size {
        width: 100%;
        max-width: 720px;
        justify-content: flex-start;
        padding: 0;
      }

      .gh-portal-popup-container.full-size {
        width: 100vw;
        min-height: 100vh;
        justify-content: flex-start;
        animation: popup-full-size 0.25s ease-in-out;
        margin: 0;
        border-radius: 0;
        transform: translateY(0px);
        transform-origin: top;
        padding: 2vmin 6vmin;
        padding-bottom: 4vw;
      }

      .gh-portal-popup-container.preview {
        animation: none !important;
      }

      .gh-portal-popup-wrapper.preview.offer {
        padding-top: 0;
      }

      .gh-portal-popup-container.preview.offer {
        max-width: 420px;
        transform: scale(0.9);
        margin-top: 3.2vw;
      }

      @media (max-width: 480px) {
        .gh-portal-popup-container.preview.offer {
          transform-origin: top;
          margin-top: 0;
        }
      }

      @keyframes popup {
        0% {
          transform: translateY(-30px);
          opacity: 0;
        }

        1% {
          transform: translateY(30px);
          opacity: 0;
        }

        100% {
          transform: translateY(0);
          opacity: 1.0;
        }
      }

      @keyframes popup-full-size {
        0% {
          transform: translateY(0px);
          opacity: 0;
        }

        1% {
          transform: translateY(30px);
          opacity: 0;
        }

        100% {
          transform: translateY(0);
          opacity: 1.0;
        }
      }

      /* Sets the main content area of the popup scrollable.
      /* 12vw is the sum horizontal padding of the popup container
      */
      .gh-portal-content {
        position: relative;
      }

      /* Hide scrollbar for Chrome, Safari and Opera */
      .gh-portal-content::-webkit-scrollbar {
        display: none;
      }

      /* Hide scrollbar for IE, Edge and Firefox */
      .gh-portal-content {
        -ms-overflow-style: none;
        /* IE and Edge */
        scrollbar-width: none;
        /* Firefox */
      }

      .gh-portal-closeicon-container {
        position: fixed;
        top: 24px;
        right: 24px;
        z-index: 10000;
      }

      .gh-portal-closeicon {
        color: var(--grey10);
        cursor: pointer;
        width: 20px;
        height: 20px;
        padding: 12px;
        transition: all 0.2s ease-in-out;
      }

      .gh-portal-closeicon:hover {
        color: var(--grey5);
      }

      .gh-portal-popup-wrapper.full-size .gh-portal-closeicon-container,
      .gh-portal-popup-container.full-size .gh-portal-closeicon-container {
        top: 20px;
        right: 20px;
      }

      .gh-portal-popup-wrapper.full-size .gh-portal-closeicon,
      .gh-portal-popup-container.full-size .gh-portal-closeicon {
        color: var(--grey6);
        width: 24px;
        height: 24px;
      }

      .gh-portal-logout-container {
        position: absolute;
        top: 8px;
        left: 8px;
      }

      .gh-portal-header {
        display: flex;
        flex-direction: column;
        align-items: center;
        padding-bottom: 24px;
      }

      .gh-portal-section {
        margin-bottom: 40px;
      }

      .gh-portal-section.form {
        margin-bottom: 20px;
      }

      .gh-portal-section.flex {
        display: flex;
        flex-direction: column;
        gap: 2rem;
      }

      .gh-portal-detail-header {
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: -2px 0 40px;
      }

      .gh-portal-detail-footer .gh-portal-btn {
        min-width: 90px;
      }

      .gh-portal-action-footer {
        display: flex;
        align-items: center;
        justify-content: space-between;
        flex-direction: column;
        gap: 12px;
      }

      .gh-portal-footer-secondary {
        display: flex;
        font-size: 14.5px;
        letter-spacing: 0.3px;
      }

      .gh-portal-footer-secondary button {
        font-size: 14.5px;
      }

      .gh-portal-footer-secondary-light {
        color: var(--grey7);
      }

      .gh-portal-list+.gh-portal-action-footer {
        margin-top: 40px;
      }

      .gh-portal-list {
        background: var(--white);
        padding: 20px;
        border-radius: 8px;
        border: 1px solid var(--grey12);
      }

      .gh-portal-list section {
        display: flex;
        align-items: center;
        margin: 0 -20px 20px;
        padding: 0 20px 20px;
        border-bottom: 1px solid var(--grey12);
      }

      .gh-portal-list section:last-of-type {
        margin-bottom: 0;
        padding-bottom: 0;
        border: none;
      }

      .gh-portal-list-detail {
        flex-grow: 1;
      }

      .gh-portal-list-detail h3 {
        font-size: 1.5rem;
        font-weight: 600;
      }

      .gh-portal-list-detail p {
        font-size: 1.45rem;
        letter-spacing: 0.3px;
        line-height: 1.3em;
        padding: 0;
        margin: 5px 8px 0 0;
        color: var(--grey6);
        word-break: break-word;
      }

      .gh-portal-list-toggle-wrapper {
        align-items: flex-start !important;
        justify-content: space-between;
      }

      .gh-portal-list-toggle-wrapper .gh-portal-list-detail {
        padding: 4px 24px 4px 0px;
      }

      .gh-portal-cookiebanner {
        background: var(--red);
        color: var(--white);
        text-align: center;
        font-size: 1.4rem;
        letter-spacing: 0.2px;
        line-height: 1.4em;
        padding: 5px;
      }

      /* Icons
      /* ----------------------------------------------------- */
      .gh-portal-icon {
        color: var(--brand-color);
      }

      /* Spacing modifiers
      /* ----------------------------------------------------- */
      .hidden {
        display: none !important;
      }

      .gh-portal-account-header {
        display: flex;
        flex-direction: column;
        align-items: center;
        margin: 0 0 32px
      }

      .gh-portal-account-header .gh-portal-avatar {
        margin: 6px 0 8px !important
      }

      .gh-portal-account-data {
        margin-bottom: 40px
      }

      footer.gh-portal-account-footer {
        display: flex
      }

      .gh-portal-account-footermenu {
        display: flex;
        align-items: center;
        list-style: none;
        padding: 0;
        margin: 0
      }

      .gh-portal-account-footerright {
        display: flex;
        flex-grow: 1;
        align-items: center;
        justify-content: flex-end
      }

      .gh-portal-account-footermenu li {
        margin-inline-end: 16px
      }

      .gh-portal-account-footermenu li:last-of-type {
        margin-inline-end: 0
      }

      @media (max-width: 390px) {
        .gh-portal-account-footer {
          padding: 0 !important
        }
      }

      @media (max-width: 340px) {
        .gh-portal-account-footer {
          padding: 0 !important;
          flex-wrap: wrap;
          gap: 12px
        }

        .gh-portal-account-footer .gh-portal-account-footerright {
          justify-content: flex-start
        }
      }

      .gh-portal-input-section.hidden {
        display: none;
      }

      .gh-portal-input {
        -webkit-appearance: none;
        -moz-appearance: none;
        appearance: none;
        display: block;
        box-sizing: border-box;
        font-size: 1.5rem;
        color: inherit;
        background: transparent;
        outline: none;
        border: 1px solid var(--grey11);
        border-radius: 6px;
        width: 100%;
        height: 44px;
        padding: 0 12px;
        margin-bottom: 16px;
        letter-spacing: 0.2px;
        transition: border-color 0.25s ease-in-out;
      }

      .gh-portal-input-labelcontainer {
        display: flex;
        justify-content: space-between;
        width: 100%;
      }

      .gh-portal-input-labelcontainer p {
        color: var(--red);
        font-size: 1.3rem;
        letter-spacing: 0.35px;
        line-height: 1.6em;
        margin-bottom: 0;
      }

      .gh-portal-input-error {
        color: var(--red) !important;
        font-size: 1.3rem;
        letter-spacing: 0.35px;
        line-height: 1.6em;
        margin-bottom: 0;
        margin-top: 4px;
      }

      .gh-portal-input.error {
        border-color: var(--red) !important;
      }

      .gh-portal-input-label.hidden {
        display: none;
      }

      .gh-portal-input:focus {
        border-color: var(--grey8);
      }

      .gh-portal-loadingicon {
        width: 20px !important;
        height: 20px !important;
        margin-left: 8px;
        vertical-align: middle;
      }

      .gh-portal-input::placeholder {
        color: var(--grey8);
      }

      .gh-portal-popup-container:not(.preview) .gh-portal-input:disabled {
        background: var(--grey13);
        color: var(--grey9);
        box-shadow: none;
      }

      .gh-portal-popup-container:not(.preview) .gh-portal-input:disabled::placeholder {
        color: var(--grey9);
      }

      .gh-portal-btn-product {
        position: sticky;
        bottom: 0;
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        width: 100%;
        justify-self: flex-end;
        padding: 40px 0 32px;
        margin-bottom: -32px;
        background: transparent;
      }

      .gh-portal-btn-product::before {
        position: absolute;
        content: "";
        display: block;
        top: -16px;
        left: 0;
        right: 0;
        bottom: 0;
        background: linear-gradient(0deg, rgba(var(--whitergb), 1) 60%, rgba(var(--whitergb), 0) 100%);
        z-index: 800;
      }

      .gh-portal-btn-product:not(.gh-portal-btn-unsubscribe) .gh-portal-btn {
        background: var(--brand-color);
        color: var(--white);
        border: none;
        width: 100%;
        z-index: 900;
      }

      .gh-portal-btn-product:not(.gh-portal-btn-unsubscribe) .gh-portal-btn:hover {
        opacity: 0.9;
      }

      .gh-portal-btn-product:not(.gh-portal-btn-unsubscribe) .gh-portal-btn {
        background: var(--brand-color);
        color: var(--white);
        border: none;
        width: 100%;
        z-index: 900;
      }

      .gh-portal-btn-product .gh-portal-error-message {
        z-index: 900;
        color: var(--red);
        font-size: 1.4rem;
        min-height: 40px;
        padding-bottom: 13px;
        margin-bottom: -40px;
      }

      /* Upgrade and change plan*/
      .gh-portal-btn-main {
        box-shadow: none;
        position: relative;
        border: none;
      }

      .gh-portal-btn-main:hover,
      .gh-portal-btn-main:focus {
        box-shadow: none;
        border: none;
      }

      .gh-portal-btn-primary:hover,
      .gh-portal-btn-primary:focus {
        opacity: 0.75 !important;
      }

      .gh-portal-btn-primary:disabled:hover::before {
        display: none;
      }

      .gh-portal-btn-destructive:not(:disabled):hover {
        color: var(--red);
        border-color: var(--red);
      }

      .gh-portal-btn-text {
        padding: 0;
        font-weight: 500;
        height: unset;
        border: none;
        box-shadow: none;
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

      .gh-portal-btn-back,
      .gh-portal-btn-back:hover {
        box-shadow: none;
        position: relative;
        height: unset;
        min-width: unset;
        position: fixed;
        top: 29px;
        left: 20px;
        background: none;
        padding: 8px;
        margin: 0;
        box-shadow: none;
        color: var(--grey3);
        border: none;
        z-index: 10000;
      }

      @media (max-width: 480px) {
        .gh-portal-btn-back,
        .gh-portal-btn-back:hover {
          left: 16px;
        }
      }

      .gh-portal-btn-back:hover {
        color: var(--grey1);
        transform: translateX(-4px);
      }

      .gh-portal-btn-back svg {
        width: 17px;
        height: 17px;
        margin-top: 1px;
        margin-inline-end: 2px;
      }

      .gh-portal-avatar {
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
        overflow: hidden;
        margin: 0 0 8px 0;
        border-radius: 999px;
      }

      .gh-portal-avatar img {
        position: absolute;
        display: block;
        top: -2px;
        right: -2px;
        bottom: -2px;
        left: -2px;
        width: calc(100% + 4px);
        height: calc(100% + 4px);
        opacity: 1;
        max-width: unset;
      }

      .gh-portal-icon-envelope {
        width: 44px;
        margin: 12px 0 10px;
      }

      .gh-portal-authorization-logo {
        position: relative;
        display: block;
        background-position: 50%;
        background-size: cover;
        border-radius: 2px;
        width: 60px;
        height: 60px;
        margin: 12px 0 10px;
      }

      .gh-portal-signup-header,
      .gh-portal-signin-header {
        display: flex;
        flex-direction: column;
        align-items: center;
        padding: 0 32px;
        margin-bottom: 32px;
      }

      .gh-portal-popup-wrapper.full-size .gh-portal-signup-header {
        margin-top: 32px;
      }

      .gh-portal-signup-header .gh-portal-main-title,
      .gh-portal-signin-header .gh-portal-main-title {
        margin-top: 12px;
      }

      .gh-portal-authorization-logo+.gh-portal-main-title {
        margin: 4px 0 0;
      }

      .gh-portal-signup-header .gh-portal-main-subtitle {
        font-size: 1.5rem;
        text-align: center;
        line-height: 1.45em;
        margin: 4px 0 0;
        color: var(--grey3);
      }

      .gh-portal-logged-out-form-container {
        width: 100%;
        max-width: 420px;
        margin: 0 auto;
      }

      .gh-portal-signup-message {
        display: flex;
        justify-content: center;
        color: var(--grey4);
        font-size: 1.5rem;
        margin: 16px 0 0;
      }

      .gh-portal-signup-message,
      .gh-portal-signup-message * {
        z-index: 9999;
      }

      .full-size .gh-portal-signup-message {
        margin: 24px 0 40px;
      }

      @media (max-width: 480px) {
        .preview .gh-portal-products+.gh-portal-signup-message {
          margin-bottom: 40px;
        }
      }

      footer.gh-portal-signup-footer,
      footer.gh-portal-signin-footer {
        display: flex;
        flex-direction: column;
        align-items: center;
        position: relative;
        padding-top: 24px;
        height: unset;
      }

      .gh-portal-content.signup,
      .gh-portal-content.signin {
        max-height: unset !important;
        padding-bottom: 0;
      }

      .gh-portal-content.signin {
        padding-bottom: 4px;
      }

      .gh-portal-content.signup .gh-portal-section {
        margin-bottom: 0;
      }

      .gh-portal-content.signin .gh-portal-section {
        margin-bottom: 0;
      }

      .gh-portal-popup-wrapper.full-size .gh-portal-popup-container.preview footer.gh-portal-signup-footer {
        padding-bottom: 32px;
      }

      @media (min-width: 480px) {}

      @media (max-width: 480px) {
        .gh-portal-authorization-logo {
          width: 48px;
          height: 48px;
        }
      }

      @media (max-width: 1440px) {
        .gh-portal-popup-container.large-size {
          width: 100%;
          max-width: 600px;
        }

        .gh-portal-input {
          height: 42px;
          margin-bottom: 16px;
        }

        button[class="gh-portal-btn"],
        .gh-portal-btn-main,
        .gh-portal-btn-primary {
          height: 42px;
        }
      }

      @media (min-width: 520px) {
        .gh-portal-popup-wrapper.full-size .gh-portal-popup-container.preview {
          box-shadow:
            0 0 0 1px rgba(var(--blackrgb), 0.02),
            0 2.8px 2.2px rgba(var(--blackrgb), 0.02),
            0 6.7px 5.3px rgba(var(--blackrgb), 0.028),
            0 12.5px 10px rgba(var(--blackrgb), 0.035),
            0 22.3px 17.9px rgba(var(--blackrgb), 0.042),
            0 41.8px 33.4px rgba(var(--blackrgb), 0.05),
            0 100px 80px rgba(var(--blackrgb), 0.07);
          animation: none;
          margin: 32px;
          padding: 32px 32px 0;
          width: calc(100vw - 64px);
          height: calc(100vh - 160px);
          min-height: unset;
          border-radius: 12px;
          overflow: auto;
          justify-content: flex-start;
        }
      }

      @media (max-width: 480px) {
        .gh-portal-detail-header {
          margin-top: 4px;
        }

        .gh-portal-popup-wrapper {
          height: 100%;
          padding: 0;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: space-between;
          background: var(--white);
          overflow-y: auto;
        }

        .gh-portal-popup-container {
          width: 100% !important;
          border-radius: 0;
          overflow: unset;
          animation: popup-mobile 0.25s ease-in-out;
          box-shadow: none !important;
          transform: translateY(0);
          padding: 28px !important;
        }

        .gh-portal-popup-container.full-size {
          justify-content: flex-start;
        }

        .gh-portal-popup-container.large-size {
          padding: 0 !important;
        }

        .gh-portal-popup-wrapper.account-home,
        .gh-portal-popup-container.account-home {
          background: var(--grey13);
        }

        .gh-portal-popup-wrapper.full-size .gh-portal-closeicon,
        .gh-portal-popup-container.full-size .gh-portal-closeicon {
          width: 16px;
          height: 16px;
        }
      }

      @media (max-width: 390px) {
        .gh-portal-popup-container:not(.account-plan) .gh-portal-detail-header .gh-portal-main-title {
          font-size: 2.1rem;
          margin-top: 1px;
          padding: 0 74px;
          text-align: center;
        }

        .gh-portal-input {
          margin-bottom: 16px;
        }

        .gh-portal-signup-header,
        .gh-portal-signin-header {
          padding-bottom: 16px;
        }
      }

      @media (min-width: 480px) and (max-height: 880px) {
        .gh-portal-popup-wrapper {
          padding: 4vmin 0 0;
        }
      }

      @keyframes popup-mobile {
        0% {
          opacity: 0;
        }

        100% {
          opacity: 1.0;
        }
      }

      /* Prevent zoom */
      @media (hover:none) {

        select,
        textarea,
        input[type="text"],
        input[type="text"],
        input[type="password"],
        input[type="datetime"],
        input[type="datetime-local"],
        input[type="date"],
        input[type="month"],
        input[type="time"],
        input[type="week"],
        input[type="number"],
        input[type="email"],
        input[type="url"] {
          font-size: 16px !important;
        }
      }

      .gh-portal-popup-wrapper.multiple-products .gh-portal-input-section {
        max-width: 420px;
        margin: 0 auto;
      }

      /* Multiple product signup/signin-only modifications! */
      .gh-portal-popup-wrapper.multiple-products {
        background: #fff;
        box-shadow: 0 3.8px 2.2px rgba(var(--blackrgb), 0.028), 0 9.2px 5.3px rgba(var(--blackrgb), 0.04), 0 17.3px 10px rgba(var(--blackrgb), 0.05), 0 30.8px 17.9px rgba(var(--blackrgb), 0.06), 0 57.7px 33.4px rgba(var(--blackrgb), 0.072), 0 138px 80px rgba(var(--blackrgb), 0.1);
        padding: 0;
        border-radius: 5px;
        height: calc(100vh - 64px);
        max-width: calc(100vw - 64px);
      }

      .gh-portal-popup-wrapper.multiple-products.signup {
        overflow-y: scroll;
        overflow-x: clip;
        margin: 32px auto !important;
        padding-inline-end: 0 !important;
        /* Override scrollbar hiding */
      }

      .gh-portal-popup-wrapper.multiple-products.signin {
        margin: 10vmin auto;
        max-width: 480px;
        height: unset;
      }

      .gh-portal-popup-wrapper.multiple-products.preview {
        height: calc(100vh - 150px) !important;
      }

      .gh-portal-popup-wrapper.multiple-products .gh-portal-popup-container {
        align-items: center;
        width: 100% !important;
        box-shadow: none !important;
        animation: fadein 0.35s ease-in-out;
        padding: 1vmin 0;
        transform: translateY(0px);
        margin-bottom: 0;
      }

      .gh-portal-popup-wrapper.multiple-products.signup .gh-portal-popup-container {
        min-height: calc(100vh - 64px);
        position: unset;
      }

      .gh-portal-popup-wrapper.multiple-products .gh-portal-powered {
        position: relative;
        display: flex;
        flex: 1;
        align-items: flex-end;
        justify-content: flex-start;
        bottom: unset;
        left: unset;
        width: 100%;
        z-index: 10000;
        padding-bottom: 32px;
      }

      @media (max-width: 670px) {
        .gh-portal-popup-wrapper.multiple-products .gh-portal-powered {
          justify-content: center;
        }
      }

      .gh-portal-popup-wrapper.multiple-products .gh-portal-content {
        position: unset;
        overflow-y: visible;
        max-height: unset !important;
      }

      @media (max-width: 960px) {
        .gh-portal-popup-wrapper.multiple-products.signup:not(.preview) {
          margin: 20px !important;
          height: 100%;
        }
      }

      @media (max-width: 480px) {
        .gh-portal-popup-wrapper.multiple-products {
          margin: 0 !important;
          max-width: unset !important;
          max-height: 100% !important;
          height: 100% !important;
          border-radius: 0px;
          box-shadow: none;
        }

        .gh-portal-popup-wrapper.multiple-products.signup:not(.preview) {
          margin: 0 !important;
        }

        .gh-portal-popup-wrapper.multiple-products.preview {
          height: unset !important;
          margin: 0 !important;
        }

        .gh-portal-popup-wrapper.multiple-products:not(.dev) .gh-portal-popup-container.preview {
          max-height: 640px;
        }
      }

      .gh-portal-popup-container.preview * {
        pointer-events: none !important;
      }

      .gh-portal-unsubscribe-logo {
        width: 60px;
        height: 60px;
        border-radius: 2px;
        margin-top: 12px;
        margin-bottom: 6px;
      }

      @media (max-width: 480px) {
        .gh-portal-unsubscribe-logo {
          width: 48px;
          height: 48px;
        }
      }

      .gh-portal-unsubscribe .gh-portal-main-title {
        margin-bottom: 16px;
        font-size: 2.6rem;
      }

      .gh-portal-unsubscribe p {
        margin-bottom: 16px;
      }

      .gh-portal-unsubscribe p:last-of-type {
        margin-bottom: 0;
      }

      .gh-portal-btn-inline {
        display: inline-block;
        margin-inline-start: 4px;
        font-size: 1.5rem;
        font-weight: 600;
        cursor: pointer;
      }

      .gh-portal-toggle-checked {
        transition: all 0.3s;
        transition-delay: 2s;
      }

      .gh-portal-checkmark-container {
        display: flex;
        opacity: 0;
        margin-inline-end: 8px;
        transition: opacity ease 0.4s 0.2s;
      }

      .gh-portal-checkmark-show {
        opacity: 1;
      }

      .gh-portal-checkmark-icon {
        height: 22px;
        color: #30cf43;
      }

      @keyframes fadeIn {
        0% {
          opacity: 0;
        }

        100% {
          opacity: 1;
        }
      }

      @keyframes fadeOut {
        0% {
          opacity: 1;
        }

        100% {
          opacity: 0;
        }
      }

      .gh-portal-newsletter-selection {
        animation: 0.5s ease-in-out fadeIn;
      }

      .gh-portal-signup,
      .gh-portal-signin {
        animation: 0.5s ease-in-out fadeIn;
      }

      .gh-portal-btn-different-plan {
        margin: 0 auto 24px;
        color: var(--grey6);
        font-weight: 400;
      }

      .gh-portal-hide {
        display: none;
      }

      .gh-portal-feedback {}

      .gh-portal-feedback .gh-feedback-icon {
        padding: 10px 0;
        text-align: center;
        color: var(--brand-color);
        width: 48px;
        margin: 0 auto;
      }

      .gh-portal-feedback .gh-feedback-icon.gh-feedback-icon-error {
        color: #f50b23;
        width: 96px;
      }

      .gh-portal-feedback .gh-portal-text-center {
        padding: 16px 32px 12px;
      }

      .gh-portal-confirm-title {
        line-height: inherit;
        text-align: center;
        box-sizing: border-box;
        margin: 0;
        margin-bottom: .4rem;
        font-size: 24px;
        font-weight: 700;
        letter-spacing: -.018em;
      }

      .gh-portal-confirm-button {
        width: 100%;
        margin-top: 3.6rem;
      }

      .gh-feedback-buttons-group {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 16px;
        margin-top: 3.6rem;
      }

      .gh-feedback-button {
        position: relative;
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 8px;
        font-size: 1.4rem;
        line-height: 1.2;
        font-weight: 700;
        border: none;
        border-radius: 22px;
        padding: 12px 8px;
        color: #505050;
        background: none;
        cursor: pointer;
      }

      .gh-feedback-button::before {
        content: '';
        position: absolute;
        width: 100%;
        height: 100%;
        left: 0;
        top: 0;
        border-radius: inherit;
        background: currentColor;
        opacity: 0.10;
      }

      .gh-feedback-button-selected {
        box-shadow: inset 0 0 0 2px currentColor;
      }

      .gh-feedback-button svg {
        width: 24px;
        height: 24px;
        color: inherit;
      }

      .gh-feedback-button svg path {
        stroke-width: 4px;
      }

      @media (max-width: 480px) {
        .gh-portal-popup-background {
          animation: none;
        }

        .gh-portal-popup-wrapper.feedback h1 {
          font-size: 2.5rem;
        }

        .gh-portal-popup-wrapper.feedback p {
          margin-bottom: 1.2rem;
        }

        .gh-portal-feedback .gh-portal-text-center {
          padding-inline-start: 8px;
          padding-inline-end: 8px;
        }

        .gh-portal-popup-wrapper.feedback {
          display: block;
          position: relative;
          width: 100%;
          background: none;
          padding-inline-end: 0 !important;
          overflow: hidden;
          overflow-y: hidden !important;
          animation: none;
        }

        .gh-portal-popup-container.feedback {
          position: absolute;
          bottom: 0;
          left: 0;
          right: 0;
          border-radius: 18px 18px 0 0;
          margin: 0 !important;
          animation: none;
          animation: mobile-tray-from-bottom 0.4s ease;
        }

        .gh-portal-popup-wrapper.feedback .gh-portal-closeicon-container {
          display: none;
        }

        .gh-feedback-buttons-group,
        .gh-portal-confirm-button {
          margin-top: 28px;
        }

        .gh-portal-powered.outside.feedback {
          display: none;
        }

        @keyframes mobile-tray-from-bottom {
          0% {
            opacity: 0;
            transform: translateY(300px);
          }

          20% {
            opacity: 1.0;
          }

          100% {
            transform: translateY(0);
          }
        }
      }

      .gh-email-suppressed-page-title {
        margin-bottom: 14px
      }

      .gh-email-suppressed-page-icon {
        display: block;
        width: 38px;
        height: 38px;
        margin: 0 auto 18px
      }

      .gh-email-suppressed-page-text {
        padding: 0 14px;
        text-align: center;
        color: var(--grey6)
      }

      .gh-email-faq-footer-text {
        color: var(--grey8)
      }

      .gh-portal-list-detail.email-newsletter .gh-email-faq-page-button {
        display: block;
        margin-top: 3px
      }

      .gh-portal-action-footer .gh-email-faq-page-button {
        margin-inline-start: 4px
      }

      .emailReceivingFAQ .gh-portal-btn-back,
      .emailReceivingFAQ .gh-portal-btn-back:hover {
        left: calc(6vmin - 14px)
      }

      .emailReceivingFAQ .gh-portal-closeicon-container {
        right: calc(6vmin - 20px)
      }

      @media (max-width: 480px) {
        .emailReceivingFAQ .gh-portal-btn-back,
        .emailReceivingFAQ .gh-portal-btn-back:hover {
          left: 16px
        }

        .emailReceivingFAQ .gh-portal-closeicon-container {
          right: 24px
        }
      }

      .gh-email-faq-page-button {
        color: var(--brand-color);
        cursor: pointer;
        background: none;
        transition: color linear .1s;
        font-size: 1.45rem
      }

      .gh-portal-tips-and-donations .gh-portal-signup-header {
        margin-bottom: 12px;
        padding: 0;
      }

      .gh-portal-tips-and-donations .gh-tips-and-donations-icon-success {
        margin: 24px auto 16px;
        text-align: center;
        color: var(--brand-color);
        width: 48px;
        height: 48px;
      }

      .gh-portal-tips-and-donations .gh-tips-and-donations-icon-success svg {
        width: 48px;
        height: 48px;
      }

      .gh-portal-tips-and-donations h1.gh-portal-main-title {
        font-size: 32px;
      }

      .gh-portal-tips-and-donations .gh-portal-text-center {
        padding: 16px 32px 12px;
      }

      .gh-portal-tips-and-donations .gh-tips-and-donations-icon-error {
        padding: 10px 0;
        text-align: center;
        width: 48px;
        margin: 0 auto;
        color: #f50b23;
      }

      .gh-portal-tips-donations .gh-tips-donations-icon.gh-feedback-icon-error {
        color: #f50b23;
        width: 96px;
      }

      .gh-portal-tips-and-donations .gh-portal-text-center {
        padding: 16px 32px 12px;
      }

      .gh-portal-recommendations-header .gh-portal-main-title {
        padding: 0 32px;
      }

      .gh-portal-recommendation-item {
        min-height: 38px;
      }

      .gh-portal-recommendation-item .gh-portal-list-detail {
        padding: 4px 24px 4px 0px;
      }

      .gh-portal-recommendation-item-header {
        display: flex;
        align-items: center;
        gap: 10px;
        cursor: pointer;
      }

      .gh-portal-recommendation-item-favicon {
        width: 20px;
        height: 20px;
        border-radius: 3px;
      }

      .gh-portal-recommendations-header {
        display: flex;
        flex-direction: column;
        align-items: center;
        margin-bottom: 20px;
      }

      .gh-portal-recommendations-description {
        text-align: center;
      }

      .gh-portal-recommendation-description-container {
        position: relative;
      }

      .gh-portal-recommendation-item .gh-portal-recommendation-description-container p {
        font-size: 1.35rem;
        padding-inline-start: 30px;
        font-weight: 400;
        letter-spacing: 0.1px;
        margin-top: 4px;
      }

      .gh-portal-recommendation-description-hidden {
        visibility: hidden;
      }

      .gh-portal-recommendation-item .gh-portal-list-detail {
        transition: 0.2s ease-in-out opacity;
      }

      .gh-portal-list-detail:hover {
        cursor: pointer;
        opacity: 0.8;
      }

      .gh-portal-recommendation-arrow-icon {
        height: 12px;
        opacity: 0;
        margin-inline-start: -6px;
        transition: 0.2s ease-in opacity;
      }

      .gh-portal-recommendation-arrow-icon path {
        stroke-width: 3px;
        stroke: #555;
      }

      .gh-portal-recommendation-item .gh-portal-list-detail:hover .gh-portal-recommendation-arrow-icon {
        opacity: 0.8;
      }

      .gh-portal-recommendation-item .gh-portal-btn-list {
        height: 28px;
      }

      .gh-portal-recommendation-subscribed {
        display: flex;
        padding-inline-start: 30px;
        align-items: center;
        gap: 4px;
        font-size: 1.35rem;
        font-weight: 400;
        letter-spacing: 0.1px;
        line-height: 1.3em;
        animation: 0.5s ease-in-out fadeIn;
      }

      .gh-portal-recommendation-subscribed.with-description {
        position: absolute;
      }

      .gh-portal-recommendation-subscribed.without-description {
        margin-top: 5px;
      }

      .gh-portal-recommendation-subscribed span {
        color: var(--grey6);
      }

      .gh-portal-recommendation-checkmark-icon {
        height: 16px;
        width: 16px;
        padding: 0 2px;
        color: #30cf43;
      }

      .gh-portal-recommendation-item .gh-portal-loadingicon {
        position: relative !important;
        height: 24px;
      }

      .gh-portal-recommendation-item-action {
        min-height: 28px;
      }

      .gh-portal-popup-container.recommendations .gh-portal-action-footer .gh-portal-btn-recommendations-later {
        margin: 8px auto 24px;
        color: var(--grey6);
        font-weight: 400;
      }

      /* OTP */
      .gh-portal-otp {
        display: flex;
        flex-direction: column;
        align-items: center;
        margin-bottom: 12px;
      }

      .gh-portal-otp-container {
        border: 1px solid var(--grey12);
        border-radius: 8px;
        width: 100%;
        transition: border-color 0.25s ease;
      }

      .gh-portal-otp-container.focused {
        border-color: var(--grey8);
      }

      .gh-portal-otp-container.error {
        border-color: var(--red);
        box-shadow: 0 0 0 3px rgba(255, 0, 0, 0.1);
      }

      .gh-portal-otp .gh-portal-input {
        margin: 0 auto;
        font-size: 2rem !important;
        font-weight: 300;
        border: none;
        /*text-align: center;*/
        padding-left: 2ch;
        padding-right: 1ch;
        letter-spacing: 1ch;
        font-family: Consolas, Liberation Mono, Menlo, Courier, monospace;
        width: 15ch;
      }

      .gh-portal-otp-error {
        margin-top: 8px;
        color: var(--red);
        font-size: 1.3rem;
        letter-spacing: 0.35px;
        line-height: 1.6em;
        margin-bottom: 0;
      }

      @media (max-width: 1440px) {
        .gh-portal-popup-container:not(.full-size):not(.large-size):not(.preview) {
          width: 480px;
        }

        .gh-portal-popup-container.large-size {
          width: 100%;
          max-width: 600px;
        }

        .gh-portal-input {
          height: 42px;
          margin-bottom: 16px;
        }

        button[class="gh-portal-btn"],
        .gh-portal-btn-main,
        .gh-portal-btn-primary {
            height: 42px;
        }
      }

      .gh-portal-for-switch label,
      .gh-portal-for-switch .container {
        position: relative;
        display: inline-block;
        width: 44px !important;
        height: 26px !important;
        cursor: pointer;
      }

      .gh-portal-for-switch label p,
      .gh-portal-for-switch .container p {
        overflow: auto;
        color: var(--grey0);
        font-weight: normal;
      }

      .gh-portal-for-switch input {
        opacity: 0;
        width: 0;
        height: 0;
      }

      .gh-portal-for-switch .input-toggle-component {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: var(--grey12);
        transition: .3s;
        width: 44px !important;
        height: 26px !important;
        border-radius: 999px;
        transition: background 0.15s ease-in-out, border-color 0.15s ease-in-out;
        cursor: pointer;
      }

      .gh-portal-for-switch label:hover input:not(:checked) + .input-toggle-component,
      .gh-portal-for-switch .container:hover input:not(:checked) + .input-toggle-component {
        border-color: var(--grey9);
      }

      .gh-portal-for-switch .input-toggle-component:before {
        position: absolute;
        content: "";
        top: 3px !important;
        left: 3px !important;
        height: 20px !important;
        width: 20px !important;
        background-color: var(--white);
        transition: .3s;
        border-radius: 999px;
      }

      .gh-portal-for-switch input:checked + .input-toggle-component {
        background: var(--brand-color);
        border-color: transparent;
      }

      .gh-portal-for-switch input:checked + .input-toggle-component:before {
        transform: translateX(18px);
        box-shadow: none;
      }

      .gh-portal-for-switch .container {
        width: 38px !important;
        height: 22px !important;
      }
    `;

    // CSS 로드 완료 이벤트
    style.onload = () => {
      console.log("✅ Account Modal CSS loaded successfully");
    };

    style.onerror = () => {
      console.error("❌ Failed to load account modal CSS");
    };

    document.head.appendChild(style);
  }

  // 모달 CSS 제거
  unloadModalCSS() {
    const link = document.getElementById("account-modal-css");
    if (link) {
      console.log("🗑️ Unloading Account modal CSS...");
      link.remove();
      console.log("✅ Account Modal CSS unloaded");
    }
  }

  // Account 모달 열기
  async open(event) {
    event.preventDefault();

    console.log("🚀 Opening account modal");

    // 모달 CSS 로드 (열 때마다)
    this.loadModalCSS();

    // Body 스크롤 방지
    document.body.style.overflow = "hidden";

    // #account-root 표시
    if (this.rootElement) {
      this.rootElement.style.display = "block";
    }

    // 최신 사용자 정보를 API에서 가져오기
    // await this.fetchAndUpdateUserData()

    // 짧은 지연 후 모달 표시 (DOM이 렌더링된 후 Target이 초기화될 시간을 줌)
    setTimeout(() => {
      // 기본값은 home 모달
      const mode = event.detail?.mode || "home";
      console.log("📋 Mode:", mode);

      // 요청된 모드로 전환
      if (mode === "edit") {
        this.switchToEdit();
      } else if (mode === "manage") {
        this.switchToManage();
      } else {
        this.switchToHome();
      }

      console.log("✅ Account Modal opened in mode:", mode);
    }, 100);
  }

  // [로컬] DOM에서 사용자 정보 업데이트
  updateUserDataInDOM(nickname, email) {
    console.log("Account - updateUserDataInDOM Initialized...");

    try {
      // Home modal의 사용자 정보 업데이트
      const homeModal = this.element.querySelector('[data-account-target="homeModal"]');
      if (homeModal) {
        // Nickname 업데이트 (h3 태그)
        const nicknameElement = homeModal.querySelector("h3");
        if (nicknameElement) {
          nicknameElement.textContent = nickname;
        }

        // Email 업데이트 (p 태그)
        const emailElement = homeModal.querySelector("p");
        if (emailElement) {
          emailElement.textContent = email;
        }

        // Avatar 업데이트 (minidenticon-svg의 username 속성)
        const avatarElement = homeModal.querySelector("minidenticon-svg");
        if (avatarElement) {
          avatarElement.setAttribute("username", nickname);
        }

        console.log("✅ User data updated in home modal");
      }

      // Edit modal의 input 값 업데이트
      if (this.hasEditNicknameTarget) {
        this.editNicknameTarget.value = nickname;
      }
      if (this.hasEditEmailTarget) {
        this.editEmailTarget.value = email;
      }

      console.log("✅ User data updated in edit modal inputs");
    } catch (error) {
      console.error("❌ Error updating user data in DOM:", error);
    }
  }

  // Account 모달 닫기
  close() {
    // Submit 진행 중에는 모달을 닫지 않음
    if (this.isSubmitting) {
      console.log("⏸️ Submit in progress, modal cannot be closed");
      return;
    }

    console.log("🔒 Closing account modal");

    // Body 스타일 복원
    document.body.style.overflow = "";

    // #account-root 숨김
    if (this.rootElement) {
      this.rootElement.style.display = "none";
    }

    // 입력 필드 초기화
    this.clearFields();

    // 메시지 초기화
    this.clearMessages();

    // 모드를 기본값(home)으로 초기화
    this.currentMode = "home";
    console.log("🔄 Mode reset to:", this.currentMode);

    // 모달 CSS 제거 (닫을 때마다)
    this.unloadModalCSS();
  }

  // 이벤트 전파 중단 (모달 컨테이너 내부 클릭 시)
  // 모달 안쪽을 클릭해도 모달이 닫히지 않도록 함
  stopPropagation(event) {
    event.stopPropagation();
  }

  // 모달 열림 상태 확인
  isOpen() {
    if (this.rootElement) {
      return this.rootElement.style.display !== "none";
    }
    return false;
  }

  // Submit 시작 (모달 닫기 비활성화)
  startSubmit() {
    this.isSubmitting = true;
    console.log("🔒 Submit started - modal closing disabled");
  }

  // Submit 종료 (모달 닫기 활성화)
  endSubmit() {
    this.isSubmitting = false;
    console.log("🔓 Submit ended - modal closing enabled");
  }

  // 회원정보 홈 모달 동적 표시
  showAccountModal(type, name = null, email = null) {
    if (!this.hasWrapperTarget || !this.hasContainerTarget) return;

    try {
      // 사용자 데이터 가져오기
      const userData = this.getUserData();
      const userName = name || userData?.name || "";
      const userEmail = email || userData?.email || "";

      if (type === "home") {
        const wrapperElement = this.wrapperTarget;
        const containerElement = this.containerTarget;

        // wrapper와 container의 클래스 초기화 후 home 추가
        wrapperElement.className = "gh-portal-popup-wrapper account-home";
        containerElement.className = "gh-portal-popup-container account-home";

        // wrapper와 container 클래스 변경
        if (this.hasWrapperTarget) {
          this.wrapperTarget.className = "gh-portal-popup-wrapper account-home";
        }
        if (this.hasContainerTarget) {
          this.containerTarget.className = "gh-portal-popup-container account-home";
        }

        this.containerTarget.innerHTML = `
          <div class="gh-portal-account-wrapper" data-account-target="homeModal">
            <div class="gh-portal-content gh-portal-account-main">
              <!-- 닫기 아이콘 -->
              <div class="gh-portal-closeicon-container" data-action="click->account#close">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="gh-portal-closeicon" alt="Close">
                  <defs>
                    <style>.a{fill: none;stroke:currentColor;stroke-linecap:round;stroke-linejoin:round;stroke-width:1.2px!important;}</style>
                  </defs>
                  <path class="a" d="M.75 23.249l22.5-22.5M23.25 23.249L.75.749"></path>
                </svg>
              </div>
              <header class="gh-portal-account-header">
                <figure class="gh-portal-avatar">
                  <!-- MinIdenticon Avatar -->
                  <minidenticon-svg username="${userName}"></minidenticon-svg>
                </figure>
                <h2 class="gh-portal-main-title">Your account</h2>
              </header>
              <section class="gh-portal-account-data">
                <div>
                  <div class="gh-portal-list">
                    <section>
                      <div class="gh-portal-list-detail">
                        <h3>${userName}</h3>
                        <p>${userEmail}</p>
                      </div>
                      <button class="gh-portal-btn gh-portal-btn-list" data-account-target="editProfileButton" data-action="click->account#switchToEdit">Edit</button>
                    </section>
                    <section>
                      <div class="gh-portal-list-detail">
                        <h3>Emails</h3>
                        <p>Update your preferences</p>
                      </div>
                      <button class="gh-portal-btn gh-portal-btn-list" data-account-target="manageSubscriptionButton" data-action="click->account#switchToManage">Manage</button>
                    </section>
                  </div>
                </div>
              </section>
            </div>
            <footer class="gh-portal-account-footer">
              <ul class="gh-portal-account-footermenu">
                <li>
                  <button data-account-target="logout" data-action="click->account#handleLogout" class="gh-portal-btn" name="logout" aria-label="logout">Log out</button>
                </li>
              </ul>
              <div class="gh-portal-account-footerright">
                <ul class="gh-portal-account-footermenu">
                  <li>
                    <a class="gh-portal-btn gh-portal-btn-branded" href="mailto:noreply@kamillee.life">Contact support</a>
                  </li>
                </ul>
              </div>
            </footer>
          </div>
        `;

        console.log("✅ Account home modal created");
      } else if (type === "edit") {
        const wrapperElement = this.wrapperTarget;
        const containerElement = this.containerTarget;

        // wrapper와 container의 클래스 초기화 후 profile 추가
        wrapperElement.className = "gh-portal-popup-wrapper account-profile";
        containerElement.className = "gh-portal-popup-container account-profile";

        // wrapper와 container 클래스 변경
        if (this.hasWrapperTarget) {
          this.wrapperTarget.className = "gh-portal-popup-wrapper account-profile";
        }
        if (this.hasContainerTarget) {
          this.containerTarget.className = "gh-portal-popup-container account-profile";
        }

        this.containerTarget.innerHTML = `
          <!-- 회원정보 수정(edit) 모달 Start -->
          <form class="gh-portal-content with-footer" data-account-target="editModal" data-action="submit->account#handleAccountEdit">
            <div class="gh-portal-closeicon-container" data-test-button="close-popup">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="gh-portal-closeicon" data-action="click->account#close" alt="Close">
                <defs>
                  <style>.a{fill:none;stroke:currentColor;stroke-linecap:round;stroke-linejoin:round;stroke-width:1.2px !important;}</style>
                </defs>
                <path class="a" d="M.75 23.249l22.5-22.5M23.25 23.249L.75.749"></path>
              </svg>
            </div>
            <header class="gh-portal-detail-header">
              <button class="gh-portal-btn gh-portal-btn-back" data-account-target="backToHomeButton" data-action="click->account#switchToHome" type="button">
                <svg id="Regular" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                  <defs>
                    <style>.cls-1{fill:none;stroke:currentColor;stroke-linecap:round;stroke-linejoin:round;stroke-width:1.5px;fill-rule:evenodd;}</style>
                  </defs>
                  <path class="cls-1" d="M16.25,23.25,5.53,12.53a.749.749,0,0,1,0-1.06L16.25.75"></path>
                </svg>
                Back
              </button>
              <h3 class="gh-portal-main-title">Account settings</h3>
            </header>
            <div class="gh-portal-section">
              <div class="gh-portal-section">
                <section class="gh-portal-input-section">
                  <div class="gh-portal-input-labelcontainer">
                    <label class="gh-portal-input-label" data-account-target="editNicknameError">Nickname</label>
                  </div>
                  <input id="input-nickname" class="gh-portal-input" type="text" name="nickname" placeholder="Kamil Lee" autocomplete="off" autocorrect="off" autocapitalize="" aria-label="Nickname" data-account-target="input editNickname" value="${userName}">
                </section>
                <section class="gh-portal-input-section">
                  <div class="gh-portal-input-labelcontainer">
                    <label class="gh-portal-input-label" data-account-target="editEmailError">Email</label>
                  </div>
                  <input id="input-email" class="gh-portal-input" type="email" name="email" placeholder="kamillee0918@email.com" autocomplete="off" autocorrect="off" autocapitalize="none" aria-label="Email" data-account-target="input editEmail" value="${userEmail}">
                </section>
              </div>
            </div>
            <footer class="gh-portal-action-footer">
              <button class="gh-portal-btn gh-portal-btn-main gh-portal-btn-primary" style="color: rgb(255, 255, 255); background-color: var(--brand-color); opacity: 1; pointer-events: auto; width: 100%;" type="submit" data-account-target="editProfileSubmitButton">Save</button>
            </footer>
          </form>
        `;

        console.log("✅ Account edit modal created");
      } else if (type === "manage") {
        const wrapperElement = this.wrapperTarget;
        const containerElement = this.containerTarget;

        // wrapper와 container의 클래스 초기화 후 manage 추가
        wrapperElement.className = "gh-portal-popup-wrapper account-manage";
        containerElement.className = "gh-portal-popup-container account-manage";

        // wrapper와 container 클래스 변경
        if (this.hasWrapperTarget) {
          this.wrapperTarget.className = "gh-portal-popup-wrapper account-manage";
        }
        if (this.hasContainerTarget) {
          this.containerTarget.className = "gh-portal-popup-container account-manage";
        }

        this.containerTarget.innerHTML = `
          <!-- 회원구독 설정(manage) 모달 Start -->
          <div class="gh-portal-content with-footer" data-account-target="manageModal">
            <div class="gh-portal-closeicon-container" data-test-button="close-popup">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="gh-portal-closeicon" data-action="click->account#close" alt="Close" data-testid="close-popup">
                <defs>
                  <style>.a{fill:none;stroke:currentColor;stroke-linecap:round;stroke-linejoin:round;stroke-width:1.2px !important;}</style>
                </defs>
                <path class="a" d="M.75 23.249l22.5-22.5M23.25 23.249L.75.749"></path>
              </svg>
            </div>
            <header class="gh-portal-detail-header">
              <button class="gh-portal-btn gh-portal-btn-back" data-action="click->account#switchToHome">
                <svg id="Regular" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
                  <defs>
                    <style>.cls-1{fill:none;stroke:currentColor;stroke-linecap:round;stroke-linejoin:round;stroke-width:1.5px;fill-rule:evenodd;}</style>
                  </defs>
                  <path class="cls-1" d="M16.25,23.25,5.53,12.53a.749.749,0,0,1,0-1.06L16.25.75"></path>
                </svg>
                Back
              </button>
              <h3 class="gh-portal-main-title">Email preferences</h3>
            </header>
            <div class="gh-portal-section flex">
              <div class="gh-portal-list">
                <section class="gh-portal-list-toggle-wrapper" data-testid="toggle-wrapper">
                  <div class="gh-portal-list-detail">
                    <h3>KamilLee's Newsletter</h3>
                    <p>It notifies new posts</p>
                  </div>
                  <div style="display: flex; align-items: center;">
                    <div class="gh-portal-for-switch" data-test-switch="switch-input">
                      <label class="switch">
                        <input type="checkbox" id="newsletter-toggle" aria-label="Newsletter subscription toggle" ${
                          userData?.enable_newsletter_notifications ? "checked" : ""
                        } data-action="change->account#handleEmailNotificationPreferences">
                        <span class="input-toggle-component" data-testid="switch-input"></span>
                      </label>
                    </div>
                  </div>
                </section>
              </div>
            </div>
            <div class="gh-portal-btn-product gh-portal-btn-unsubscribe" style="margin-top: -48px; margin-bottom: 0px;">
              <button class="gh-portal-btn gh-portal-btn-destructive" style="opacity: 1; pointer-events: auto; width: 100%; z-index: 900;" type="button" data-action="click->account#handleUnsubscribeAll" data-test-button="unsubscribe-from-all-emails">Unsubscribe from all emails</button>
            </div>
            <footer class="gh-portal-action-footer gh-feature-suppressions">
              <div style="width: 100%;"></div>
              <div class="gh-portal-footer-secondary">
                <span class="gh-portal-footer-secondary-light">Not receiving emails?</span>
                <button class="gh-portal-btn-text gh-email-faq-page-button">
                  Get help<span class="right-arrow">→</span>
                </button>
              </div>
            </footer>
          </div>
          <!-- 회원구독 설정(manage) 모달 End -->
        `;

        console.log("✅ Account manage modal created");
      }
    } catch (error) {
      console.error("❌ Failed to show home modal:", error);
    }
  }

  // 회원정보 홈 모달로 전환
  switchToHome() {
    console.log("📝 Switching to home modal");

    // 캐시된 사용자 데이터 가져오기
    const data = this.getUserData();
    if (!data) {
      console.error("❌ No user data available");
      return;
    }

    // 회원정보 홈 모달 동적 생성
    this.showAccountModal("home", data.name, data.email);

    // 모드 변경
    this.currentMode = "home";

    console.log("✅ Switched to home mode");
  }

  // 회원정보 수정 모달로 전환
  switchToEdit() {
    console.log("📝 Switching to edit modal");

    // 캐시된 사용자 데이터 가져오기
    const data = this.getUserData();
    if (!data) {
      console.error("❌ No user data available");
      return;
    }

    // 회원정보 수정 모달 동적 생성
    this.showAccountModal("edit", data.name, data.email);

    // 모드 변경
    this.currentMode = "edit";

    console.log("✅ Switched to edit mode");
  }

  // 이메일 구독 설정 모달로 전환
  switchToManage() {
    console.log("🔑 Switching to manage modal");

    // 캐시된 사용자 데이터 가져오기
    const data = this.getUserData();
    if (!data) {
      console.error("❌ No user data available");
      return;
    }

    // 이메일 구독 설정 모달 동적 생성
    this.showAccountModal("manage", data.name, data.email);

    // 모드 변경
    this.currentMode = "manage";

    console.log("✅ Switched to manage mode");
  }

  // 입력 필드 초기화
  clearFields() {
    if (this.hasSignupNicknameTarget) {
      this.signupNicknameTarget.value = "";
    }
    if (this.hasSignupEmailTarget) {
      this.signupEmailTarget.value = "";
    }
    if (this.hasSigninEmailTarget) {
      this.signinEmailTarget.value = "";
    }
  }

  // [로컬] 메시지 초기화
  clearMessages() {
    // input 필드에서 error 클래스 제거
    if (this.hasInputTarget) {
      this.inputTargets.forEach(element => {
        element.classList.remove("error");
      });
    }

    // 에러 메시지 제거(모든 에러 메시지 제거)
    if (this.hasEditNicknameErrorTarget || this.hasEditEmailErrorTarget) {
      console.info("EditNicknameErrorTarget found:", this.hasEditNicknameErrorTarget);
      console.info("EditEmailErrorTarget found:", this.hasEditEmailErrorTarget);

      // 모든 errorMessageTaget 제거
      const errorParagraphs = this.element.querySelectorAll("[data-account-target='errorMessage']");
      if (errorParagraphs) {
        console.log("✅ Error message found");
        errorParagraphs.forEach(element => {
          element.remove();
        });
      } else {
        console.log("❌ Error message not found");
      }
    }

    console.log("✅ Error messages cleared");
  }

  // 계정 정보 수정 폼 제출 처리
  async handleAccountEdit(event) {
    event.preventDefault();

    // 메시지 초기화
    this.clearMessages();

    const nickname = this.editNicknameTarget.value.trim();
    const email = this.editEmailTarget.value.trim();

    console.log("👤 Nickname:", nickname);
    console.log("📧 Email:", email);

    // 클라이언트 검증 - 두 필드 모두 비어있는 경우 먼저 체크
    if (!nickname && !email) {
      this.showMessage("editNicknameError", "Enter your nickname");
      this.showMessage("editEmailError", "Enter your email address");
      return;
    }

    // 개별 필드 검증
    if (!nickname) {
      this.showMessage("editNicknameError", "Enter your nickname");
      return;
    }

    if (!email) {
      this.showMessage("editEmailError", "Enter your email address");
      return;
    }

    if (!this.isGlobalValidEmail(email)) {
      this.showMessage("editEmailError", "Invalid email address");
      return;
    }

    console.log("📝 Account Edit attempt:", { nickname, email });

    // 버튼 비활성화 및 Submit 시작 (모달 닫기 방지)
    this.setGlobalButtonContent(this.editProfileSubmitButtonTarget, true, false);
    this.startSubmit();

    try {
      // 1. 캐시된 사용자 정보 가져오기 (GET 요청 제거)
      const globalController = this.getGlobalController();
      const currentUser = globalController ? globalController.getCachedUserData() : null;

      if (!currentUser) {
        throw new Error("No cached user data available. Please refresh the page.");
      }

      console.log("📋 Using cached user data:", currentUser);

      // 원본 데이터 저장
      this.originalUserData = {
        nickname: currentUser.name || currentUser.firstname,
        email: currentUser.email,
      };

      // 2. 변경 사항 확인
      const nicknameChanged = nickname !== this.originalUserData.nickname;
      const emailChanged = email !== this.originalUserData.email;

      console.log("🔍 Changes detected:", {
        nicknameChanged,
        emailChanged,
        original: this.originalUserData,
        new: { nickname, email },
      });

      // 변경 사항이 없으면 종료
      if (!nicknameChanged && !emailChanged) {
        console.log("ℹ️ No changes detected");
        this.showGlobalNotification("No changes to save", "success");
        this.endSubmit();
        this.setGlobalButtonContent(this.editProfileSubmitButtonTarget, false, false);
        return;
      }

      // 3. 변경 사항에 따라 API 호출
      if (nicknameChanged && !emailChanged) {
        // 닉네임만 변경
        await this.updateNickname(nickname);
      } else if (!nicknameChanged && emailChanged) {
        // 이메일만 변경
        await this.updateEmail(email);
      } else {
        // 둘 다 변경: 닉네임 먼저 변경 → 세션 확인 → 이메일 변경
        await this.updateNicknameAndEmail(nickname, email);
      }
    } catch (error) {
      console.error("❌ Account edit error:", error);
      this.showGlobalNotification(error.message || "Failed to update account, please try again", "error");
      this.endSubmit();
    } finally {
      // 버튼 복원
      this.setGlobalButtonContent(this.editProfileSubmitButtonTarget, false, false);
    }
  }

  // 닉네임만 업데이트
  async updateNickname(nickname) {
    console.log("📝 Updating nickname only:", nickname);

    const response = await fetch("/members/api/member", {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.getGlobalCSRFToken(),
      },
      body: JSON.stringify({
        name: nickname,
      }),
    });

    const data = await response.json();

    if (response.ok) {
      console.log("✅ Nickname updated successfully:", data);

      // Global controller의 캐시 갱신
      const globalController = this.getGlobalController();
      if (globalController) {
        const refreshedData = await globalController.refreshUserData();
        console.log("🔄 Global cache refreshed after nickname update");

        // Account controller의 캐시도 동기화
        this.currentUserData = refreshedData;
        console.log("🔄 Account cache synced with global cache:", refreshedData);
      }

      // 성공 notification 표시
      this.showGlobalNotification("Account details updated successfully", "success");

      // 입력 필드 업데이트
      if (this.hasEditNicknameTarget) {
        this.editNicknameTarget.value = nickname;
      }

      // Home 모달로 전환
      setTimeout(() => {
        this.switchToHome();
      }, 100);
    } else {
      console.error("❌ Failed to update nickname:", data);
      throw new Error(data.errors?.[0] || "Failed to update nickname");
    }
  }

  // 이메일만 업데이트
  async updateEmail(email) {
    console.log("📧 Updating email only:", email);

    // 1. 세션에서 identity 토큰 가져오기
    const sessionResponse = await fetch("/members/api/session", {
      method: "GET",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.getGlobalCSRFToken(),
      },
    });

    if (!sessionResponse.ok) {
      throw new Error("Failed to get session identity");
    }

    const sessionData = await sessionResponse.json();
    const identity = sessionData.identity;

    if (!identity) {
      throw new Error("No identity token found in session");
    }

    console.log("🔐 Identity token retrieved", identity);

    // 2. 이메일 변경 요청
    const response = await fetch("/members/api/member/email", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.getGlobalCSRFToken(),
      },
      body: JSON.stringify({
        email: email,
        identity: identity,
      }),
    });

    const data = await response.json();

    if (response.ok) {
      console.log("✅ Email update request sent:", data);

      // 이메일 인증 안내 메시지
      this.showNotification("Please check your email to verify the change", "success");

      // 개발 환경에서는 콘솔에 확인 링크 표시 (서버 로그 확인 필요)
      console.log("📧 Email verification required. Check Rails console for verification link.");

      // 즉시 Home 모달로 전환
      setTimeout(() => {
        this.switchToHome();
      }, 0);
    } else {
      console.error("❌ Failed to update email:", data);
      throw new Error(data.errors?.[0] || "Failed to update email");
    }
  }

  // 닉네임과 이메일 모두 업데이트
  async updateNicknameAndEmail(nickname, email) {
    console.log("📝 Updating both nickname and email:", { nickname, email });

    // 1. 닉네임 먼저 업데이트
    await this.updateNickname(nickname);

    // 2. 이메일 업데이트
    await this.updateEmail(email);
  }

  // 로그아웃 처리
  async handleLogout(event) {
    event.preventDefault();
    console.log("🔓 Logout button clicked");

    if (!this.hasLogoutTarget) {
      console.error("❌ Logout target not found");
      return;
    }

    // 버튼 비활성화 및 Submit 시작 (모달 닫기 방지)
    this.setGlobalButtonContent(this.logoutTarget, false, false);
    this.startSubmit();

    try {
      // DELETE /members/api/session - 세션 삭제 및 로그아웃
      const response = await fetch("/members/api/session", {
        method: "DELETE",
        headers: {
          Accept: "application/json",
          "Content-Type": "application/json",
          "X-CSRF-Token": this.getGlobalCSRFToken(),
        },
      });

      // 200 OK 또는 302 Found 모두 성공으로 처리
      if (response.ok || response.status === 302) {
        console.log("✅ Logout successful");

        // 페이지 리로드
        window.location.href = "/";
      } else {
        const data = await response.json().catch(() => ({ error: "Logout failed" }));
        console.error("❌ Logout failed:", data);

        // 에러 notification 표시
        if (this.hasNotificationTarget) {
          this.showGlobalNotification(data.error || "Logout failed", "error");
        }
      }
    } catch (error) {
      console.error("❌ Logout error:", error);

      // 에러 notification 표시
      if (this.hasNotificationTarget) {
        this.showGlobalNotification("네트워크 오류가 발생했습니다. 다시 시도해주세요.", "error");
      }
    } finally {
      // 버튼 복원
      this.setGlobalButtonContent(this.logoutTarget, false, false);
    }
  }

  // 이메일 알림 구독/구독 해지 (Newsletter)
  async handleEmailNotificationPreferences(event) {
    const checkbox = event.target;
    const isEnabled = checkbox.checked;

    console.log("📧 Newsletter preference changed:", isEnabled);

    try {
      // Newsletter 구독 설정 변경
      await this.toggleNewsletter(isEnabled);
    } catch (error) {
      console.error("❌ Failed to update newsletter preferences:", error);

      // 에러 발생 시 체크박스 상태 복원
      checkbox.checked = !isEnabled;

      this.showGlobalNotification("Failed to update newsletter preferences", "error");
    }
  }

  // 모든 이메일 구독 해지(Newsletter, Comment(TODO))
  async handleUnsubscribeAll(event) {
    event.preventDefault();

    console.log("📧 Unsubscribing from all emails...");

    try {
      // Newsletter 구독 해지
      await this.toggleNewsletter(false);

      // 체크박스 상태 업데이트
      const checkbox = document.getElementById("newsletter-toggle");
      if (checkbox) {
        checkbox.checked = false;
      }
    } catch (error) {
      console.error("❌ Failed to unsubscribe from all emails:", error);
      this.showGlobalNotification("Failed to unsubscribe from all emails", "error");
    }
  }

  // Newsletter 구독/구독 해지
  async toggleNewsletter(enable) {
    console.log("📧 Newsletter toggle requested:", enable);

    const response = await fetch("/members/api/member", {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.getGlobalCSRFToken(),
      },
      body: JSON.stringify({
        enable_newsletter_notifications: enable,
      }),
    });

    const data = await response.json();

    if (response.ok) {
      console.log("✅ Newsletter setting updated:", data);

      // Newsletter 구독/구독 해지 안내 메시지
      const message = enable ? "You've subscribed to the newsletter" : "You've unsubscribed from the newsletter";
      this.showGlobalNotification(message, "success");
    } else {
      console.error("❌ Newsletter setting update failed:", data);
      this.showGlobalNotification("Failed to update newsletter preferences", "error");
      throw new Error("Newsletter update failed");
    }
  }

  // ===== Global Controller Helper 메서드 =====
  // Global controller 인스턴스 가져오기
  getGlobalController() {
    const globalController = this.application.getControllerForElementAndIdentifier(document.body, "global");

    if (!globalController) {
      console.error("❌ Global controller not found");
    }

    return globalController;
  }

  // [로컬] 사용자 데이터 가져오기 (Global 캐시 우선)
  getUserData() {
    // 1. Global controller의 캐시 확인 (Single Source of Truth)
    const globalController = this.getGlobalController();
    if (globalController) {
      const globalData = globalController.getCachedUserData();
      if (globalData) {
        // Account controller 캐시 동기화
        this.currentUserData = globalData;
        return globalData;
      }
    }

    // 2. Fallback: Account controller의 캐시 확인
    if (this.currentUserData) {
      console.warn("⚠️ Using stale Account cache (Global cache unavailable)");
      return this.currentUserData;
    }

    // 3. 데이터 없음
    console.warn("⚠️ No cached user data available");
    return null;
  }

  // [호출] 키보드 단축키 처리 (Escape)
  handleGlobalKeyboard(event) {
    const globalController = this.application.getControllerForElementAndIdentifier(document.body, "global");

    if (globalController) {
      // Global controller의 handleKeyboard 호출
      globalController.handleKeyboard(event, {
        // onEscape: Escape 키를 눌렀을 때 실행할 함수
        onEscape: () => this.close(),
        // condition: 키 이벤트를 처리할 조건 (모달이 열려있는지 확인)
        condition: () => this.isOpen(),
      });
    } else {
      console.error("❌ Global controller not found");
    }
  }

  // [호출] 유효한 이메일 주소인지 검사
  isGlobalValidEmail(email) {
    const globalController = this.getGlobalController();
    if (globalController) {
      return globalController.isValidEmail(email);
    }
  }

  // [로컬] 에러 메시지 표시
  showMessage(targetName, message) {
    // label 태그 찾기 (target은 label 요소)
    const labelTarget = this[`${targetName}Target`];
    if (!labelTarget) {
      console.warn(`⚠️ Target not found: ${targetName}`);
      return;
    }

    // 기존 에러 메시지 제거 (있으면)
    const existingError = labelTarget.querySelector("p");
    if (existingError) {
      console.log("✅ Existing error message found");
      existingError.remove();
    } else {
      console.log("❌ Existing error message not found");
    }

    // 새 에러 메시지 p 태그 생성 및 추가
    const errorParagraph = document.createElement("p");
    errorParagraph.textContent = message;
    errorParagraph.setAttribute("data-account-target", "errorMessage");
    labelTarget.parentNode.insertBefore(errorParagraph, labelTarget.nextSibling);

    console.log(`✅ Error message displayed: ${message}`);

    // 해당 input 필드에 error 클래스 추가
    // targetName이 "editNicknameError"이면 "editNickname" input을 찾음
    const inputFieldName = targetName.replace("Error", "");
    const inputField = this[`${inputFieldName}Target`];

    if (inputField) {
      inputField.classList.add("error");
      console.log(`✅ Error class added to input: ${inputFieldName}`);
    }
  }

  // [호출] notification 표시
  showGlobalNotification(message, type = "success", nickname = null) {
    const globalController = this.getGlobalController();
    if (globalController) {
      globalController.showNotification(message, type, nickname);
    }
  }

  // [호출] buttonLoading 표시
  setGlobalButtonContent(button, isLoading, hasError) {
    const globalController = this.getGlobalController();
    if (globalController) {
      globalController.setButtonContent(button, isLoading, hasError);
    }
  }

  // [호출] CSRF 토큰 가져오기
  getGlobalCSRFToken() {
    const globalController = this.getGlobalController();
    return globalController ? globalController.getCSRFToken() : "";
  }
}

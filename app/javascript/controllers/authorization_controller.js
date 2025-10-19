import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="authorization"
export default class extends Controller {
  static targets = [
    "wrapper",
    "container",
    "overlay",
    "signupForm",
    "signinForm",
    "signupNickname",
    "signupEmail",
    "signinEmail",
    "signupButton",
    "signinButton"
  ]

  connect() {
    console.log("🔐 Authorization controller connected")
    console.log("📍 Targets:", {
      wrapper: this.hasWrapperTarget,
      container: this.hasContainerTarget,
      overlay: this.hasOverlayTarget,
      signupForm: this.hasSignupFormTarget,
      signinForm: this.hasSigninFormTarget,
    })

    // #authorization-root 요소 참조 저장
    this.rootElement = document.getElementById("authorization-root")

    // 초기 상태: 로그인 폼 표시
    this.currentMode = "signin"
  }

  disconnect() {
    console.log("🔓 Authorization controller disconnected")

    // 모달 CSS 제거
    this.unloadModalCSS()
  }

  // 모달 전용 CSS 로드
  loadModalCSS() {
    // 이미 로드되어 있는지 확인
    if (document.getElementById("authorization-modal-css")) {
      console.log("✅ Authorization Modal CSS already loaded")
      return
    }

    console.log("📦 Loading authorization modal CSS...")

    const style = document.createElement("style")
    style.id = "authorization-modal-css"
    style.textContent = `
      /* Globals
      /* ----------------------------------------------------- */
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

      textarea {
        padding: 10px;
        line-height: 1.5em;
      }

      .gh-longform {
        padding: 56px 6vmin 6vmin;
      }

      .gh-longform p {
        color: var(--grey3);
        margin-bottom: 1.2em;
      }

      .gh-longform p:last-of-type {
        margin-bottom: 0.2em;
      }

      .gh-longform h3 {
        font-size: 27px;
        margin-top: 0px;
        margin-bottom: 0.25em;
      }

      .gh-longform h4 {
        font-size: 17.5px;
        margin-top: 1.85em;
        margin-bottom: 0.4em;
      }

      .gh-longform h5 {
        margin-top: 0.8em;
        margin-bottom: 0.2em;
      }

      .gh-longform a {
        color: var(--brand-color);
        font-weight: 500;
      }

      .gh-longform strong {
        color: var(--grey1);
      }

      .gh-longform .ul {
        text-decoration: underline;
      }

      .gh-longform .gh-portal-btn {
        width: calc(100% + 4vmin);
        margin-top: 4rem;
        margin-inline-end: -4vmin;
      }

      .gh-longform .gh-portal-btn.no-margin-right {
        margin-inline-end: 0;
        width: 100%;
      }

      .gh-longform .gh-portal-btn-text {
        color: var(--brand-color);
        cursor: pointer;
        background: none;
        transition: color linear 100ms;
        font-size: 1.45rem;
        text-decoration: underline;
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

        .gh-longform {
          padding: 10vmin 28px;
        }

        .gh-desktop-only {
          display: none;
        }
      }

      @media (min-width: 481px) {
        .gh-mobile-only {
          display: none;
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

      .gh-portal-setting-data {
        color: var(--grey6);
        font-size: 1.3rem;
        line-height: 1.15em;
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
        color: var(--grey0);
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

      html[dir="rtl"] .gh-portal-btn-logout {
        left: unset;
        right: 24px;
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

      .gh-portal-btn-site-title-back {
        transition: transform 0.25s ease-in-out;
        z-index: 10000;
      }

      .gh-portal-btn-site-title-back span {
        margin-inline-end: 4px;
        transition: transform 0.4s cubic-bezier(0.1, 0.7, 0.1, 1);
      }

      html[dir="rtl"] .gh-portal-btn-site-title-back span {
        transform: scaleX(-1);
        -webkit-transform: scaleX(-1);
      }

      .gh-portal-btn-site-title-back:hover span {
        transform: translateX(-3px);
      }

      @media (max-width: 960px) {
        .gh-portal-btn-site-title-back {
          display: none;
        }
      }

      .gh-portal-logouticon {
        color: var(--grey9);
        cursor: pointer;
        width: 23px;
        height: 23px;
        padding: 6px;
        transform: translateX(0);
        transition: all 0.2s ease-in-out;
      }

      .gh-portal-logouticon path {
        stroke: var(--grey9);
        transition: all 0.2s ease-in-out;
      }

      .gh-portal-btn-logout:hover .gh-portal-logouticon {
        transform: translateX(-2px);
      }

      .gh-portal-btn-logout:hover .gh-portal-logouticon path {
        stroke: var(--grey3);
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

      .gh-portal-popup-container.full-size.account-plan {
        justify-content: flex-start;
        padding-top: 4vw;
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

      .gh-portal-powered {
        position: absolute;
        bottom: 24px;
        left: 24px;
        z-index: 9999;
      }

      html[dir="rtl"] .gh-portal-powered {
        left: unset;
        right: 24px;
      }

      .gh-portal-powered a {
        border: none;
        display: flex;
        align-items: center;
        line-height: 0;
        border-radius: 4px;
        background: #ffffff;
        padding: 6px 8px 6px 7px;
        color: #303336;
        font-size: 1.25rem;
        letter-spacing: -0.2px;
        font-weight: 500;
        text-decoration: none;
        transition: color 0.5s ease-in-out;
        width: 146px;
        height: 28px;
        line-height: 28px;
      }

      html[dir="rtl"] .gh-portal-powered a {
        padding: 6px 7px 6px 8px;
      }

      .gh-portal-powered a:hover {
        color: #15171A;
      }

      @keyframes powered-fade-in {
        0% {
          transform: scale(0.98);
          opacity: 0;
        }

        75% {
          opacity: 1.0;
        }

        100% {
          transform: scale(1);
        }
      }

      .gh-portal-powered a svg {
        height: 16px;
        width: 16px;
        margin: 0;
        margin-inline-end: 6px;
      }

      .gh-portal-powered.outside.full-size {
        display: none;
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

      html[dir="rtl"] .gh-portal-closeicon-container {
        right: unset;
        left: 24px;
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

      html[dir="rtl"] .gh-portal-popup-wrapper.full-size .gh-portal-closeicon-container,
      html[dir="rtl"] .gh-portal-popup-container.full-size .gh-portal-closeicon-container {
        right: unset;
        left: 20px;
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

      html[dir="rtl"] .gh-portal-logout-container {
        left: unset;
        right: 8px;
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

      .gh-portal-list-header {
        font-size: 1.25rem;
        font-weight: 500;
        color: var(--grey3);
        text-transform: uppercase;
        letter-spacing: 0.2px;
        line-height: 1.7em;
        margin-bottom: 4px;
      }

      .gh-portal-list+.gh-portal-list-header {
        margin-top: 28px;
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

      .gh-portal-newsletter-selection {
        max-width: 460px;
        margin: 0 auto;
      }

      .gh-portal-newsletter-selection .gh-portal-list {
        margin-bottom: 40px;
      }

      .gh-portal-lock-icon-container {
        display: flex;
        justify-content: center;
        flex: 44px 0 0;
        padding-top: 6px;
      }

      .gh-portal-lock-icon {
        width: 14px;
        height: 14px;
        overflow: visible;
      }

      .gh-portal-lock-icon path {
        color: var(--grey2);
      }

      .gh-portal-text-large {
        font-size: 1.8rem;
        font-weight: 600;
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

      .gh-portal-list-detail.gh-portal-list-big h3 {
        font-size: 1.6rem;
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

      html[dir="rtl"] .gh-portal-list-detail p {
        margin: 5px 0 0 8px;
      }

      .gh-portal-list-detail.gh-portal-list-big p {
        font-size: 1.5rem;
      }

      .gh-portal-list-toggle-wrapper {
        align-items: flex-start !important;
        justify-content: space-between;
      }

      .gh-portal-list-toggle-wrapper .gh-portal-list-detail {
        padding: 4px 24px 4px 0px;
      }

      html[dir="rtl"] .gh-portal-list-toggle-wrapper .gh-portal-list-detail {
        padding: 4px 0px 4px 24px;
      }

      .gh-portal-list-detail .old-price {
        text-decoration: line-through;
      }

      .gh-portal-right-arrow {
        line-height: 1;
        color: var(--grey8);
      }

      .gh-portal-right-arrow svg {
        width: 17px;
        height: 17px;
        margin-top: 1px;
        margin-inline-end: -6px;
      }

      .gh-portal-expire-warning {
        text-align: center;
        color: var(--red);
        font-weight: 500;
        font-size: 1.4rem;
        margin: 12px 0;
      }

      .gh-portal-cookiebanner {
        background: var(--red);
        color: var(--white);
        text-align: center;
        font-size: 1.4rem;
        letter-spacing: 0.2px;
        line-height: 1.4em;
        padding: 8px;
      }

      .gh-portal-publication-title {
        text-align: center;
        font-size: 1.6rem;
        letter-spacing: -.1px;
        font-weight: 700;
        text-transform: uppercase;
        color: #15212a;
        margin-top: 6px;
      }

      /* Icons
      /* ----------------------------------------------------- */
      .gh-portal-icon {
        color: var(--brand-color);
      }

      /* Spacing modifiers
      /* ----------------------------------------------------- */
      .gh-portal-strong {
        font-weight: 600;
      }

      .mt1 {
        margin-top: 4px;
      }

      .mt2 {
        margin-top: 8px;
      }

      .mt3 {
        margin-top: 12px;
      }

      .mt4 {
        margin-top: 16px;
      }

      .mt5 {
        margin-top: 20px;
      }

      .mt6 {
        margin-top: 24px;
      }

      .mt7 {
        margin-top: 28px;
      }

      .mt8 {
        margin-top: 32px;
      }

      .mt9 {
        margin-top: 36px;
      }

      .mt10 {
        margin-top: 40px;
      }

      .mr1 {
        margin-inline-end: 4px;
      }

      .mr2 {
        margin-inline-end: 8px;
      }

      .mr3 {
        margin-inline-end: 12px;
      }

      .mr4 {
        margin-inline-end: 16px;
      }

      .mr5 {
        margin-inline-end: 20px;
      }

      .mr6 {
        margin-inline-end: 24px;
      }

      .mr7 {
        margin-inline-end: 28px;
      }

      .mr8 {
        margin-inline-end: 32px;
      }

      .mr9 {
        margin-inline-end: 36px;
      }

      .mr10 {
        margin-inline-end: 40px;
      }

      .mb1 {
        margin-bottom: 4px;
      }

      .mb2 {
        margin-bottom: 8px;
      }

      .mb3 {
        margin-bottom: 12px;
      }

      .mb4 {
        margin-bottom: 16px;
      }

      .mb5 {
        margin-bottom: 20px;
      }

      .mb6 {
        margin-bottom: 24px;
      }

      .mb7 {
        margin-bottom: 28px;
      }

      .mb8 {
        margin-bottom: 32px;
      }

      .mb9 {
        margin-bottom: 36px;
      }

      .mb10 {
        margin-bottom: 40px;
      }

      .ml1 {
        margin-inline-start: 4px;
      }

      .ml2 {
        margin-inline-start: 8px;
      }

      .ml3 {
        margin-inline-start: 12px;
      }

      .ml4 {
        margin-inline-start: 16px;
      }

      .ml5 {
        margin-inline-start: 20px;
      }

      .ml6 {
        margin-inline-start: 24px;
      }

      .ml7 {
        margin-inline-start: 28px;
      }

      .ml8 {
        margin-inline-start: 32px;
      }

      .ml9 {
        margin-inline-start: 36px;
      }

      .ml10 {
        margin-inline-start: 40px;
      }

      .pt1 {
        padding-top: 4px;
      }

      .pt2 {
        padding-top: 8px;
      }

      .pt3 {
        padding-top: 12px;
      }

      .pt4 {
        padding-top: 16px;
      }

      .pt5 {
        padding-top: 20px;
      }

      .pt6 {
        padding-top: 24px;
      }

      .pt7 {
        padding-top: 28px;
      }

      .pt8 {
        padding-top: 32px;
      }

      .pt9 {
        padding-top: 36px;
      }

      .pt10 {
        padding-top: 40px;
      }

      .pr1 {
        padding-inline-end: 4px;
      }

      .pr2 {
        padding-inline-end: 8px;
      }

      .pr3 {
        padding-inline-end: 12px;
      }

      .pr4 {
        padding-inline-end: 16px;
      }

      .pr5 {
        padding-inline-end: 20px;
      }

      .pr6 {
        padding-inline-end: 24px;
      }

      .pr7 {
        padding-inline-end: 28px;
      }

      .pr8 {
        padding-inline-end: 32px;
      }

      .pr9 {
        padding-inline-end: 36px;
      }

      .pr10 {
        padding-inline-end: 40px;
      }

      .pb1 {
        padding-bottom: 4px;
      }

      .pb2 {
        padding-bottom: 8px;
      }

      .pb3 {
        padding-bottom: 12px;
      }

      .pb4 {
        padding-bottom: 16px;
      }

      .pb5 {
        padding-bottom: 20px;
      }

      .pb6 {
        padding-bottom: 24px;
      }

      .pb7 {
        padding-bottom: 28px;
      }

      .pb8 {
        padding-bottom: 32px;
      }

      .pb9 {
        padding-bottom: 36px;
      }

      .pb10 {
        padding-bottom: 40px;
      }

      .pl1 {
        padding-inline-start: 4px;
      }

      .pl2 {
        padding-inline-start: 8px;
      }

      .pl3 {
        padding-inline-start: 12px;
      }

      .pl4 {
        padding-inline-start: 16px;
      }

      .pl5 {
        padding-inline-start: 20px;
      }

      .pl6 {
        padding-inline-start: 24px;
      }

      .pl7 {
        padding-inline-start: 28px;
      }

      .pl8 {
        padding-inline-start: 32px;
      }

      .pl9 {
        padding-inline-start: 36px;
      }

      .pl10 {
        padding-inline-start: 40px;
      }

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

      .gh-portal-account-footer.paid {
        margin-top: 12px
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

      .gh-portal-freeaccount-newsletter {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-top: 24px
      }

      .gh-portal-freeaccount-newsletter .label {
        display: flex;
        flex-direction: column;
        flex-grow: 1
      }

      .gh-portal-free-ctatext {
        margin-top: -12px
      }

      .gh-portal-cancelcontinue-container {
        margin: 24px 0 32px
      }

      .gh-portal-list-detail .gh-portal-email-notice {
        display: flex;
        align-items: center;
        gap: 5px;
        margin-top: 6px;
        color: var(--red);
        font-weight: 500;
        font-size: 1.25rem;
        letter-spacing: .2px
      }

      .gh-portal-email-notice-icon {
        width: 20px;
        height: 20px
      }

      .gh-portal-billing-button-loader {
        width: 32px;
        height: 32px;
        margin-inline-end: -3px;
        opacity: .6
      }

      .gh-portal-product-icon {
        width: 52px;
        margin-inline-end: 12px;
        border-radius: 2px
      }

      .gh-portal-account-discountcontainer {
        position: relative;
        display: flex;
        align-items: center
      }

      .gh-portal-account-old-price {
        text-decoration: line-through;
        color: var(--grey9) !important
      }

      .gh-portal-account-tagicon {
        width: 16px;
        height: 16px;
        color: var(--brand-color);
        margin-inline-end: 5px;
        z-index: 999
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

      .account-plan.full-size .gh-portal-main-title {
        font-size: 3.2rem;
        margin-top: 44px;
      }

      .gh-portal-accountplans-main {
        margin-top: 24px;
        margin-bottom: 0;
      }

      .gh-portal-expire-container {
        margin: 32px 0 0;
      }

      .gh-portal-cancellation-form p {
        margin-bottom: 12px;
      }

      .gh-portal-cancellation-form .gh-portal-input-section {
        margin-bottom: 20px;
      }

      .gh-portal-cancellation-form .gh-portal-input {
        resize: none;
        width: 100%;
        height: 62px;
        padding: 6px 12px;
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
        color: var(--yellow);
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

      .gh-portal-products {
        display: flex;
        flex-direction: column;
        align-items: center;
      }

      .gh-portal-products-pricetoggle {
        position: relative;
        display: flex;
        background: #F3F3F3;
        width: 100%;
        border-radius: 999px;
        padding: 4px;
        height: 44px;
        margin: 0 0 40px;
      }

      .gh-portal-products-pricetoggle:before {
        position: absolute;
        content: "";
        display: block;
        width: 50%;
        top: 4px;
        bottom: 4px;
        right: 4px;
        background: var(--white);
        box-shadow: 0px 1px 3px rgba(var(--blackrgb), 0.08);
        border-radius: 999px;
        transition: all 0.15s ease-in-out;
      }

      html[dir="rtl"] .gh-portal-products-pricetoggle:before {
        left: 4px;
        right: unset;
      }

      .gh-portal-products-pricetoggle.left:before {
        transform: translateX(calc(-100% + 8px));
      }

      html[dir="rtl"] .gh-portal-products-pricetoggle.left:before {
        transform: translateX(calc(100% - 8px));
      }

      .gh-portal-products-pricetoggle .gh-portal-btn {
        border: 0;
        height: 100% !important;
        width: 50%;
        border-radius: 999px;
        background: transparent;
        font-size: 1.5rem;
      }

      .gh-portal-products-pricetoggle .gh-portal-btn.active {
        border: 0;
        height: 100%;
        width: 50%;
        color: var(--grey0);
      }

      .gh-portal-priceoption-label {
        font-size: 1.4rem;
        font-weight: 400;
        letter-spacing: 0.3px;
        margin: 0 6px;
        min-width: 180px;
      }

      .gh-portal-priceoption-label.monthly {
        text-align: right;
      }

      .gh-portal-priceoption-label.inactive {
        color: var(--grey8);
      }

      .gh-portal-maximum-discount {
        font-weight: 400;
        margin-inline-start: 4px;
        opacity: 0.5;
      }

      .gh-portal-products-grid {
        display: flex;
        flex-wrap: wrap;
        align-items: stretch;
        justify-content: center;
        gap: 40px;
        margin: 0 auto;
        padding: 0;
        width: 100%;
      }

      .gh-portal-product-card {
        flex: 1;
        max-width: 420px;
        min-width: 320px;
        position: relative;
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        justify-content: stretch;
        background: var(--white);
        padding: 32px;
        border-radius: 7px;
        border: 1px solid var(--grey11);
        min-height: 200px;
        transition: border-color 0.25s ease-in-out;
      }

      .gh-portal-product-card.top {
        border-bottom: none;
        border-radius: 7px 7px 0 0;
        padding-bottom: 0;
      }

      .gh-portal-product-card.bottom {
        border-top: none;
        border-radius: 0 0 7px 7px;
        padding-top: 0;
      }

      .gh-portal-product-card:not(.disabled):hover {
        border-color: var(--grey9);
      }

      .gh-portal-product-card.checked::before {
        position: absolute;
        display: block;
        top: -2px;
        right: -2px;
        bottom: -2px;
        left: -2px;
        content: "";
        z-index: 999;
        border: 0px solid var(--brand-color);
        pointer-events: none;
        border-radius: 7px;
      }

      .gh-portal-product-card-header {
        width: 100%;
        min-height: 56px;
      }

      .gh-portal-product-card-name-trial {
        display: flex;
        align-items: center;
      }

      .gh-portal-product-card-name-trial .gh-portal-discount-label {
        margin-top: -4px;
      }

      .gh-portal-product-card-details {
        flex: 1;
        display: flex;
        flex-direction: column;
        width: 100%;
      }

      .gh-portal-product-name {
        font-size: 1.8rem;
        font-weight: 600;
        line-height: 1.3em;
        letter-spacing: 0px;
        margin-top: -4px;
        word-break: break-word;
        width: 100%;
        color: var(--brand-color);
      }

      .gh-portal-discount-label-trial {
        color: var(--brand-color);
        font-weight: 600;
        font-size: 1.3rem;
        line-height: 1;
        margin-top: 4px;
      }

      .gh-portal-discount-label {
        position: relative;
        font-size: 1.25rem;
        line-height: 1em;
        font-weight: 600;
        letter-spacing: 0.3px;
        color: var(--grey0);
        padding: 6px 9px;
        text-align: center;
        white-space: nowrap;
        border-radius: 999px;
        margin-inline-end: -4px;
        max-height: 24.5px;
      }

      .gh-portal-discount-label:before {
        position: absolute;
        content: "";
        display: block;
        background: var(--brand-color);
        top: 0;
        right: 0;
        bottom: 0;
        left: 0;
        border-radius: 999px;
        opacity: 0.2;
      }

      .gh-portal-product-card-price-trial {
        display: flex;
        flex-direction: row;
        align-items: flex-end;
        justify-content: space-between;
        flex-wrap: wrap;
        row-gap: 10px;
        column-gap: 4px;
        width: 100%;
      }

      .gh-portal-product-card-pricecontainer {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
        width: 100%;
        margin-top: 16px;
      }

      .gh-portal-product-price {
        display: flex;
        justify-content: center;
        color: var(--grey0);
      }

      .gh-portal-product-price .currency-sign {
        align-self: flex-start;
        font-size: 2.7rem;
        font-weight: 700;
        line-height: 1.135em;
      }

      .gh-portal-product-price .currency-sign.long {
        margin-inline-end: 5px;
      }

      .gh-portal-product-price .amount {
        font-size: 3.5rem;
        font-weight: 700;
        line-height: 1em;
        letter-spacing: -1.3px;
        color: var(--grey0);
      }

      .gh-portal-product-price .amount.trial-duration {
        letter-spacing: -0.022em;
      }

      .gh-portal-product-price .billing-period {
        align-self: flex-end;
        font-size: 1.5rem;
        line-height: 1.6em;
        color: var(--grey5);
        letter-spacing: 0.3px;
        margin-inline-start: 5px;
      }

      .gh-portal-product-alternative-price {
        font-size: 1.3rem;
        line-height: 1.6em;
        color: var(--grey8);
        letter-spacing: 0.3px;
        display: none;
      }

      .after-trial-amount {
        display: block;
        font-size: 1.5rem;
        color: var(--grey5);
        margin-top: 6px;
        margin-bottom: 6px;
        line-height: 1;
      }

      .gh-portal-product-card-detaildata {
        flex: 1;
      }

      .gh-portal-product-description {
        font-size: 1.55rem;
        font-weight: 600;
        line-height: 1.4em;
        width: 100%;
        margin-top: 16px;
      }

      .gh-portal-product-benefits {
        font-size: 1.5rem;
        line-height: 1.4em;
        width: 100%;
        margin-top: 16px;
      }

      .gh-portal-product-benefit {
        display: flex;
        align-items: flex-start;
        margin-bottom: 10px;
      }

      .gh-portal-benefit-checkmark {
        width: 14px;
        height: 14px;
        min-width: 14px;
        margin: 3px 10px 0 0;
        overflow: visible;
      }

      html[dir="rtl"] .gh-portal-benefit-checkmark {
        margin: 3px 0 0 10px;
      }

      .gh-portal-benefit-checkmark polyline,
      .gh-portal-benefit-checkmark g {
        stroke-width: 3px;
      }

      .gh-portal-products-grid.change-plan {
        padding: 0;
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
        /*background: rgb(255,255,255);
            background: linear-gradient(0deg, rgba(255,255,255,1) 75%, rgba(255,255,255,0) 100%);*/
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

      .gh-portal-current-plan {
        display: flex;
        align-items: center;
        justify-content: center;
        text-align: center;
        white-space: nowrap;
        width: 100%;
        height: 44px;
        border-radius: 5px;
        color: var(--grey5);
        font-size: 1.4rem;
        font-weight: 500;
        line-height: 1em;
        letter-spacing: 0.2px;
        font-weight: 500;
        background: var(--grey14);
        z-index: 900;
      }

      .gh-portal-product-card.only-free {
        margin: 0 0 16px;
        min-height: unset;
      }

      .gh-portal-product-card.only-free .gh-portal-product-card-header {
        min-height: unset;
      }

      @media (max-width: 670px) {
        .gh-portal-products-grid {
          grid-template-columns: unset;
          grid-gap: 20px;
          width: 100%;
          max-width: 440px;
        }

        .gh-portal-priceoption-label {
          font-size: 1.25rem;
        }

        .gh-portal-products-priceswitch .gh-portal-discount-label {
          display: none;
        }

        .gh-portal-products-priceswitch {
          padding-top: 18px;
        }

        .gh-portal-product-card {
          min-height: unset;
        }

        .gh-portal-singleproduct-benefits .gh-portal-product-description {
          text-align: center;
        }

        .gh-portal-product-benefit:last-of-type {
          margin-bottom: 0;
        }
      }

      @media (max-width: 480px) {
        .gh-portal-product-price .amount {
          font-size: 3.4rem;
        }

        .gh-portal-product-card {
          min-width: unset;
        }

        .gh-portal-btn-product:not(.gh-portal-btn-unsubscribe) {
          position: static;
        }

        .gh-portal-btn-product:not(.gh-portal-btn-unsubscribe)::before {
          display: none;
        }
      }

      @media (max-width: 370px) {
        .gh-portal-product-price .currency-sign {
          font-size: 1.8rem;
        }

        .gh-portal-product-price .amount {
          font-size: 2.8rem;
        }
      }


      /* Upgrade and change plan*/
      .gh-portal-upgrade-product {
        margin-top: -70px;
        padding-top: 60px;
      }

      .gh-portal-upgrade-product .gh-portal-products-grid {
        grid-template-columns: unset;
        grid-gap: 20px;
        width: 100%;
      }

      .gh-portal-upgrade-product .gh-portal-product-card .gh-portal-plan-current {
        display: inline-block;
        position: relative;
        padding: 2px 8px;
        font-size: 1.2rem;
        letter-spacing: 0.3px;
        text-transform: uppercase;
        margin-bottom: 4px;
      }

      .gh-portal-upgrade-product .gh-portal-product-card .gh-portal-plan-current::before {
        position: absolute;
        content: "";
        top: 0;
        right: 0;
        bottom: 0;
        left: 0;
        border-radius: 999px;
        background: var(--brand-color);
        opacity: 0.15;
      }

      @media (max-width: 880px) {
        .gh-portal-products-grid {
          flex-direction: column;
          margin: 0 auto;
          max-width: 420px;
        }

        .gh-portal-product-card-header {
          min-height: unset;
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

      .gh-portal-for-switch label:hover input:not(:checked)+.input-toggle-component,
      .gh-portal-for-switch .container:hover input:not(:checked)+.input-toggle-component {
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

      html[dir="rtl"] .gh-portal-for-switch .input-toggle-component:before {
        left: unset !important;
        right: 3px !important;
      }

      .gh-portal-for-switch input:checked+.input-toggle-component {
        background: var(--brand-color);
        border-color: transparent;
      }

      .gh-portal-for-switch input:checked+.input-toggle-component:before {
        transform: translateX(18px);
        box-shadow: none;
      }

      html[dir="rtl"] .gh-portal-for-switch input:checked+.input-toggle-component:before {
        transform: translateX(-18px);
      }

      .gh-portal-for-switch .container {
        width: 38px !important;
        height: 22px !important;
      }

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

      html[dir="rtl"] .gh-portal-btn-text span.right-arrow {
        transform: scale(-1, 1);
        display: inline-flex;
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

      html[dir="rtl"] .gh-portal-btn-back {
        right: 20px;
        left: unset;
      }

      @media (max-width: 480px) {

        .gh-portal-btn-back,
        .gh-portal-btn-back:hover {
          left: 16px;
        }

        html[dir="rtl"] .gh-portal-btn-back {
          right: 16px;
          left: unset;
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

      html[dir="rtl"] .gh-portal-btn-back svg {
        transform: scaleX(-1);
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

      .gh-portal-inbox-notification {
        display: flex;
        flex-direction: column;
        align-items: center;
      }

      .gh-portal-inbox-notification p {
        max-width: 420px;
        text-align: center;
        margin-bottom: 30px;
      }

      .gh-portal-back-sitetitle {
        position: absolute;
        top: 35px;
        left: 32px;
      }

      html[dir="rtl"] .gh-portal-back-sitetitle {
        left: unset;
        right: 32px;
      }

      .gh-portal-back-sitetitle .gh-portal-btn {
        padding: 0;
        border: 0;
        font-size: 1.5rem;
        height: auto;
        line-height: 1em;
        color: var(--grey1);
      }

      .gh-portal-popup-wrapper:not(.full-size) .gh-portal-back-sitetitle,
      .gh-portal-popup-wrapper.preview .gh-portal-back-sitetitle {
        display: none;
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

      .gh-portal-signup-message button {
        font-size: 1.4rem;
        font-weight: 600;
        margin-inline-start: 4px !important;
        margin-bottom: -1px;
      }

      .gh-portal-signup-message button span {
        display: inline-block;
        padding-bottom: 2px;
        margin-bottom: -2px;
      }

      .gh-portal-content.signup.invite-only {
        background: none;
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

      .gh-portal-content.signup.single-field {
        margin-bottom: 4px;
      }

      .gh-portal-content.signup.single-field .gh-portal-input,
      .gh-portal-content.signin .gh-portal-input {
        margin-bottom: 12px;
      }

      .gh-portal-content.signup.single-field+.gh-portal-signup-footer,
      footer.gh-portal-signin-footer {
        padding-top: 12px;
      }

      .gh-portal-content.signin .gh-portal-section {
        margin-bottom: 0;
      }

      footer.gh-portal-signup-footer.invite-only {
        height: unset;
      }

      footer.gh-portal-signup-footer.invite-only .gh-portal-signup-message {
        margin-top: 0;
      }

      .gh-portal-invite-only-notification,
      .gh-portal-members-disabled-notification,
      .gh-portal-paid-members-only-notification {
        margin: 8px 32px 24px;
        padding: 0;
        text-align: center;
        color: var(--grey2);
      }

      .gh-portal-icon-invitation {
        width: 44px;
        height: 44px;
        margin: 12px 0 2px;
      }

      .gh-portal-popup-wrapper.full-size .gh-portal-popup-container.preview footer.gh-portal-signup-footer {
        padding-bottom: 32px;
      }

      .gh-portal-invite-only-notification+.gh-portal-signup-message,
      .gh-portal-paid-members-only-notification+.gh-portal-signup-message {
        margin-bottom: 12px;
      }

      .gh-portal-free-trial-notification {
        max-width: 480px;
        text-align: center;
        margin: 24px auto;
        color: var(--grey4);
      }

      .gh-portal-signup-terms-wrapper {
        width: 100%;
        max-width: 420px;
        margin: 0 auto;
      }

      .signup.single-field .gh-portal-signup-terms-wrapper {
        margin-top: 12px;
      }

      .signup.single-field .gh-portal-products:not(:has(.gh-portal-product-card)) {
        margin-top: -16px;
      }

      .gh-portal-signup-terms {
        margin: 0 0 36px;
      }

      .gh-portal-signup-terms-wrapper.free-only .gh-portal-signup-terms {
        margin: 0 0 24px;
      }

      .gh-portal-products:has(.gh-portal-product-card)+.gh-portal-signup-terms-wrapper.free-only {
        margin: 20px auto 0 !important;
      }

      .gh-portal-signup-terms label {
        position: relative;
        display: flex;
        gap: 10px;
        cursor: pointer;
      }

      .gh-portal-signup-terms input {
        position: absolute;
        top: 0;
        right: 0;
        bottom: 0;
        display: none;
      }

      .gh-portal-signup-terms .checkbox {
        position: relative;
        top: -1px;
        flex-shrink: 0;
        display: inline-block;
        float: left;
        width: 18px;
        height: 18px;
        margin: 1px 0 0;
        background: var(--white);
        border: 1px solid var(--grey10);
        border-radius: 4px;
        transition: background 0.15s ease-in-out, border-color 0.15s ease-in-out;
      }

      html[dir=rtl] .gh-portal-signup-terms .checkbox {
        float: right;
      }

      .gh-portal-signup-terms label:hover input:not(:checked)+.checkbox {
        border-color: var(--grey9);
      }

      .gh-portal-signup-terms .checkbox:before {
        content: "";
        position: absolute;
        top: 4px;
        left: 3px;
        width: 10px;
        height: 6px;
        border: 2px solid var(--white);
        border-top: none;
        border-right: none;
        opacity: 0;
        transition: opacity 0.15s ease-in-out;
        transform: rotate(-45deg);
      }

      html[dir=rtl] .gh-portal-signup-terms .checkbox:before {
        left: unset;
        right: 3px;
      }

      .gh-portal-signup-terms input:checked+.checkbox {
        border-color: var(--black);
        background: var(--black);
      }

      .gh-portal-signup-terms input:checked+.checkbox:before {
        opacity: 1;
      }

      .gh-portal-signup-terms.gh-portal-error .checkbox,
      .gh-portal-signup-terms.gh-portal-error label:hover input:not(:checked)+.checkbox {
        border: 1px solid var(--red);
        box-shadow: 0 0 0 3px rgb(240, 37, 37, .15);
      }

      .gh-portal-signup-terms.gh-portal-error input:checked+.checkbox {
        box-shadow: none;
      }

      .gh-portal-signup-terms-content p {
        margin-bottom: 0;
        color: var(--grey4);
        font-size: 1.4rem;
        line-height: 1.25em;
      }

      .gh-portal-error .gh-portal-signup-terms-content {
        line-height: 1.5em;
      }

      .gh-portal-signup-terms-content a {
        color: var(--brand-color);
        font-weight: 500;
        text-decoration: none;
      }

      @media (min-width: 480px) {}

      @media (max-width: 480px) {
        .gh-portal-authorization-logo {
          width: 48px;
          height: 48px;
        }
      }

      @media (min-width: 480px) and (max-width: 820px) {
        .gh-portal-powered.outside {
          left: 50%;
          transform: translateX(-50%);
        }
      }

      .gh-portal-offer {
        padding-bottom: 0;
        overflow: unset;
        max-height: unset;
      }

      .gh-portal-offer-container {
        display: flex;
        flex-direction: column;
      }

      .gh-portal-plans-container.offer {
        justify-content: space-between;
        border-color: var(--grey12);
        border-top: none;
        border-top-left-radius: 0;
        border-top-right-radius: 0;
        padding: 12px 16px;
        font-size: 1.3rem;
      }

      .gh-portal-offer-bar {
        position: relative;
        padding: 26px 28px 28px;
        margin-bottom: 24px;
        /*border: 1px dashed var(--brand-color);*/
        background-image: url("data:image/svg+xml,%3csvg width='100%25' height='99.9%25' xmlns='http://www.w3.org/2000/svg'%3e%3crect width='100%25' height='100%25' fill='none' stroke='%23C3C3C3' stroke-width='3' stroke-dasharray='3%2c 9' stroke-dashoffset='0' stroke-linecap='square'/%3e%3c/svg%3e");
        background-color: var(--white);
        border-radius: 6px;
      }

      .gh-portal-offer-title {
        display: flex;
        justify-content: space-between;
        align-items: center;
      }

      .gh-portal-offer-title h4 {
        font-size: 1.8rem;
        margin: 0 110px 0 0;
        width: 100%;
      }

      html[dir="rtl"] .gh-portal-offer-title h4 {
        margin: 0 0 0 110px;
      }

      .gh-portal-offer-title h4.placeholder {
        opacity: 0.4;
      }

      .gh-portal-offer-bar .gh-portal-discount-label {
        position: absolute;
        top: 23px;
        right: 25px;
      }

      .gh-portal-offer-bar p {
        padding-bottom: 0;
        margin: 12px 0 0;
      }

      .gh-portal-offer-title h4+p {
        margin: 12px 0 0;
      }

      .gh-portal-offer-details .gh-portal-plan-name,
      .gh-portal-offer-details p {
        margin-inline-end: 8px;
      }

      .gh-portal-offer .footnote {
        font-size: 1.35rem;
        color: var(--grey8);
        margin: 4px 0 0;
      }

      .offer .gh-portal-product-card {
        max-width: unset;
        min-height: 0;
      }

      .offer .gh-portal-product-card .gh-portal-product-card-pricecontainer:not(.offer-type-trial) {
        margin-top: 0px;
      }

      .offer .gh-portal-product-card-header {
        display: flex;
        flex-direction: column;
        align-items: flex-start;
      }

      .gh-portal-offer-oldprice {
        display: flex;
        position: relative;
        font-size: 1.8rem;
        font-weight: 300;
        color: var(--grey8);
        line-height: 1;
        white-space: nowrap;
        margin: 16px 0 4px;
      }

      .gh-portal-offer-oldprice:after {
        position: absolute;
        display: block;
        content: "";
        left: 0;
        top: 50%;
        right: 0;
        height: 1px;
        background: var(--grey8);
      }

      .gh-portal-offer-details p {
        margin-bottom: 12px;
      }

      .offer .after-trial-amount {
        margin-bottom: 0;
      }

      .offer .trial-duration {
        margin-top: 16px;
      }

      .gh-portal-cancel {
        white-space: nowrap;
      }

      .gh-portal-offer .gh-portal-signup-terms-wrapper {
        margin: 8px auto 16px;
      }

      .gh-portal-offer .gh-portal-signup-terms.gh-portal-error {
        margin: 0;
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

        .gh-portal-product-price .amount {
          font-size: 32px;
          letter-spacing: -0.022em;
        }
      }

      @media (max-width: 960px) {
        .gh-portal-powered {
          display: flex;
          position: relative;
          bottom: unset;
          left: unset;
          background: var(--white);
          justify-content: center;
          width: 100%;
          padding-top: 32px;
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

        /* Small width preview in Admin */
        .gh-portal-popup-wrapper.preview:not(.full-size) footer.gh-portal-signup-footer,
        .gh-portal-popup-wrapper.preview:not(.full-size) footer.gh-portal-signin-footer {
          padding-bottom: 32px;
        }

        .gh-portal-popup-container.preview:not(.full-size) {
          max-height: 660px;
          margin-bottom: 0;
        }

        .gh-portal-popup-container.preview:not(.full-size).offer {
          max-height: 860px;
          padding-bottom: 0 !important;
        }

        .gh-portal-popup-wrapper.preview.full-size {
          height: unset;
          max-height: 660px;
        }

        .gh-portal-popup-container.preview.full-size {
          max-height: 660px;
          margin-bottom: 0;
        }

        .preview .gh-portal-invite-only-notification+.gh-portal-signup-message,
        .preview .gh-portal-paid-members-only-notification+.gh-portal-signup-message {
          margin-bottom: 16px;
        }

        .preview .gh-portal-btn-container.sticky {
          margin-bottom: 32px;
          padding-bottom: 0;
        }

        .gh-portal-powered {
          padding-top: 12px;
          padding-bottom: 24px;
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

      html[dir="rtl"] .gh-feedback-button::before {
        right: 0;
        left: unset;
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

      html[dir=rtl] .emailReceivingFAQ .gh-portal-btn-back,
      html[dir=rtl] .emailReceivingFAQ .gh-portal-btn-back:hover {
        right: calc(6vmin - 14px);
        left: unset
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

      html[dir=rtl] .gh-email-faq-page-button span {
        transform: scaleX(-1);
        display: inline-flex
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

      html[dir="rtl"] .gh-portal-recommendation-item .gh-portal-list-detail {
        padding: 4px 0px 4px 24px;
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

      /* index.min */
      .ld-ext-right,
      .ld-ext-left,
      .ld-ext-bottom,
      .ld-ext-top,
      .ld-over,
      .ld-over-inverse,
      .ld-over-full,
      .ld-over-full-inverse {
        position: relative
      }

      .ld-ext-right>.ld,
      .ld-ext-left>.ld,
      .ld-ext-bottom>.ld,
      .ld-ext-top>.ld,
      .ld-over>.ld,
      .ld-over-inverse>.ld,
      .ld-over-full>.ld,
      .ld-over-full-inverse>.ld {
        position: absolute;
        top: 50%;
        left: 50%;
        width: 1em;
        height: 1em;
        margin: -0.5em;
        opacity: 0;
        z-index: -1;
        transition: all .3s;
        transition-timing-function: ease-in;
        animation-play-state: paused
      }

      .ld-ext-right>.ld>*,
      .ld-ext-left>.ld>*,
      .ld-ext-bottom>.ld>*,
      .ld-ext-top>.ld>*,
      .ld-over>.ld>*,
      .ld-over-inverse>.ld>*,
      .ld-over-full>.ld>*,
      .ld-over-full-inverse>.ld>* {
        width: 1em;
        height: 1em;
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-0.5em, -0.5em)
      }

      .ld-ext-right.running>.ld,
      .ld-ext-left.running>.ld,
      .ld-ext-bottom.running>.ld,
      .ld-ext-top.running>.ld,
      .ld-over.running>.ld,
      .ld-over-inverse.running>.ld,
      .ld-over-full.running>.ld,
      .ld-over-full-inverse.running>.ld {
        opacity: 1;
        z-index: auto;
        visibility: visible;
        animation-play-state: running !important
      }

      .ld-ext-right.running>.ld:before,
      .ld-ext-left.running>.ld:before,
      .ld-ext-bottom.running>.ld:before,
      .ld-ext-top.running>.ld:before,
      .ld-over.running>.ld:before,
      .ld-over-inverse.running>.ld:before,
      .ld-over-full.running>.ld:before,
      .ld-over-full-inverse.running>.ld:before,
      .ld-ext-right.running>.ld:after,
      .ld-ext-left.running>.ld:after,
      .ld-ext-bottom.running>.ld:after,
      .ld-ext-top.running>.ld:after,
      .ld-over.running>.ld:after,
      .ld-over-inverse.running>.ld:after,
      .ld-over-full.running>.ld:after,
      .ld-over-full-inverse.running>.ld:after {
        animation-play-state: running !important
      }

      .ld-ext-right,
      .ld-ext-left,
      .ld-ext-bottom,
      .ld-ext-top {
        transition-timing-function: ease-in
      }

      .ld-ext-right {
        transition: padding-right .3s
      }

      .ld-ext-right.running {
        padding-right: 2.5em !important
      }

      .ld-ext-right>.ld {
        top: 50%;
        left: auto;
        right: 1.25em
      }

      .ld-ext-left {
        transition: padding-left .3s
      }

      .ld-ext-left.running {
        padding-left: 2.5em !important
      }

      .ld-ext-left>.ld {
        top: 50%;
        right: auto;
        left: 1.25em
      }

      .ld-ext-bottom {
        transition: padding-bottom .3s
      }

      .ld-ext-bottom.running {
        padding-bottom: 2.5em !important
      }

      .ld-ext-bottom>.ld {
        top: auto;
        left: 50%;
        bottom: 1.25em
      }

      .ld-ext-top {
        transition: padding-top .3s
      }

      .ld-ext-top.running {
        padding-top: 2.5em !important
      }

      .ld-ext-top>.ld {
        bottom: auto;
        left: 50%;
        top: 1.25em
      }

      .ld-over:before,
      .ld-over-inverse:before,
      .ld-over-full:before,
      .ld-over-full-inverse:before {
        content: " ";
        display: block;
        opacity: 0;
        position: absolute;
        z-index: -1;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        transition: all .3s;
        transition-timing-function: ease-in;
        background: rgba(240, 240, 240, 0.8)
      }

      .ld-over.running>.ld,
      .ld-over-inverse.running>.ld,
      .ld-over-full.running>.ld,
      .ld-over-full-inverse.running>.ld {
        z-index: 4001
      }

      .ld-over.running:before,
      .ld-over-inverse.running:before,
      .ld-over-full.running:before,
      .ld-over-full-inverse.running:before {
        opacity: 1;
        z-index: 4000;
        display: block
      }

      .ld-over-full.running>.ld,
      .ld-over-full-inverse.running>.ld,
      .ld-over-full.running:before,
      .ld-over-full-inverse.running:before {
        position: fixed
      }

      .ld-over-full>.ld {
        color: rgba(0, 0, 0, 0.8)
      }

      .ld-over-full:before,
      .ld-over-full-inverse:before {
        background: rgba(255, 255, 255, 0.8)
      }

      .ld-over-inverse>.ld {
        color: rgba(255, 255, 255, 0.8)
      }

      .ld-over-inverse:before {
        background: rgba(0, 0, 0, 0.6)
      }

      .ld-over-full-inverse>.ld {
        color: rgba(255, 255, 255, 0.8)
      }

      .ld-over-full-inverse:before {
        background: rgba(0, 0, 0, 0.6)
      }

      .ld-over,
      .ld-over-inverse {
        isolation: isolate
      }
    `

    // CSS 로드 완료 이벤트
    style.onload = () => {
      console.log("✅ Authorization Modal CSS loaded successfully")
    }

    style.onerror = () => {
      console.error("❌ Failed to load authorization modal CSS")
    }

    document.head.appendChild(style)
  }

  // 모달 CSS 제거
  unloadModalCSS() {
    const link = document.getElementById("authorization-modal-css")
    if (link) {
      console.log("🗑️ Unloading Authorization modal CSS...")
      link.remove()
      console.log("✅ Authorization Modal CSS unloaded")
    }
  }

  // 키보드 단축키 처리 (Escape)
  handleKeyboard(event) {
    // 모달이 열려있지 않으면 무시
    if (!this.isOpen()) return

    // Escape: 모달 닫기
    if (event.key === "Escape") {
      event.preventDefault()
      this.close()
    }
  }

  // 인증 모달 열기 (이벤트에서 모드 결정)
  open(event) {
    event.preventDefault()

    console.log("🚀 Opening authorization modal")

    // 모달 CSS 로드 (열 때마다)
    this.loadModalCSS()

    // CustomEvent의 detail 또는 data-portal 속성에서 모드 결정
    const mode = event.detail?.portal || event.currentTarget?.dataset?.portal || "signin" // 기본값: signin
    console.log("📋 Mode:", mode)

    // Body 스크롤 방지
    document.body.style.overflow = "hidden"

    // #authorization-root 표시
    if (this.rootElement) {
      this.rootElement.style.display = "block"
    }

    // 짧은 지연 후 폼 전환 (DOM이 렌더링된 후 Target이 초기화될 시간을 줌)
    setTimeout(() => {
      // 요청된 모드로 전환
      if (mode === "signup") {
        this.switchToSignup()
      } else {
        this.switchToSignin()
      }

      // 입력창 포커스
      setTimeout(() => {
        if (this.currentMode === "signin" && this.hasSigninEmailTarget) {
          this.signinEmailTarget.focus()
        } else if (this.currentMode === "signup" && this.hasSignupNicknameTarget) {
          this.signupNicknameTarget.focus()
        }
      }, 50)

      console.log("✅ Authorization Modal opened in mode:", mode)
    }, 50)
  }

  // 인증 모달 닫기
  close() {
    console.log("🔒 Closing authorization modal")

    // Body 스타일 복원
    document.body.style.overflow = ""

    // #authorization-root 숨김
    if (this.rootElement) {
      this.rootElement.style.display = "none"
    }

    // 입력 필드 초기화
    this.clearFields()

    // 모드를 기본값(signin)으로 초기화
    this.currentMode = "signin"
    console.log("🔄 Mode reset to:", this.currentMode)

    // 모달 CSS 제거 (닫을 때마다)
    this.unloadModalCSS()
  }

  // 이벤트 전파 중단 (흰색 박스 클릭 시)
  stopPropagation(event) {
    event.stopPropagation()
  }

  // 모달 열림 상태 확인
  isOpen() {
    if (this.rootElement) {
      return this.rootElement.style.display !== "none"
    }
    return false
  }

  // 회원가입 폼으로 전환
  switchToSignup() {
    console.log("📝 Switching to signup form")
    console.log("🔍 Target status:", {
      hasSignupForm: this.hasSignupFormTarget,
      hasSigninForm: this.hasSigninFormTarget
    })

    if (this.hasSignupFormTarget && this.hasSigninFormTarget) {
      // Form display 변경
      this.signupFormTarget.style.display = "block"
      this.signinFormTarget.style.display = "none"
      this.currentMode = "signup"

      // wrapper와 container, content의 클래스 변경 (signin → signup)
      if (this.hasWrapperTarget) {
        this.wrapperTarget.classList.remove("signin")
        this.wrapperTarget.classList.add("signup")
      }
      if (this.hasContainerTarget) {
        this.containerTarget.classList.remove("signin")
        this.containerTarget.classList.add("signup")
      }

      // 포커스 설정
      setTimeout(() => {
        if (this.hasSignupNicknameTarget) {
          this.signupNicknameTarget.focus()
        }
      }, 100)

      console.log("✅ Switched to signup mode")
    } else {
      console.error("❌ Cannot switch to signup: Targets not found")
    }
  }

  // 로그인 폼으로 전환
  switchToSignin() {
    console.log("🔑 Switching to signin form")
    console.log("🔍 Target status:", {
      hasSignupForm: this.hasSignupFormTarget,
      hasSigninForm: this.hasSigninFormTarget
    })

    if (this.hasSignupFormTarget && this.hasSigninFormTarget) {
      // Form display 변경
      this.signupFormTarget.style.display = "none"
      this.signinFormTarget.style.display = "block"
      this.currentMode = "signin"

      // wrapper와 container, content의 클래스 변경 (signup → signin)
      if (this.hasWrapperTarget) {
        this.wrapperTarget.classList.remove("signup")
        this.wrapperTarget.classList.add("signin")
      }
      if (this.hasContainerTarget) {
        this.containerTarget.classList.remove("signin")
        this.containerTarget.classList.add("signin")
      }

      // 포커스 설정
      setTimeout(() => {
        if (this.hasSigninEmailTarget) {
          this.signinEmailTarget.focus()
        }
      }, 100)

      console.log("✅ Switched to signin mode")
    } else {
      console.error("❌ Cannot switch to signin: Targets not found")
    }
  }

  // 회원가입 폼 제출 처리
  handleSignup(event) {
    event.preventDefault()

    const nickname = this.signupNicknameTarget.value.trim()
    const email = this.signupEmailTarget.value.trim()

    console.log("📝 Signup attempt:", { nickname, email })

    // TODO: 실제 회원가입 API 호출 (Phase 4에서 구현)
    // 현재는 콘솔 로그만 출력
    alert(`회원가입 요청:\nNickname: ${nickname}\nEmail: ${email}\n\n(실제 구현은 Phase 4에서 진행됩니다)`)

    // 성공 시 모달 닫기
    // this.close()
  }

  // 로그인 폼 제출 처리
  handleSignin(event) {
    event.preventDefault()

    const email = this.signinEmailTarget.value.trim()

    console.log("🔑 Signin attempt:", { email })

    // TODO: 실제 로그인 API 호출 (Phase 4에서 구현)
    // 현재는 콘솔 로그만 출력
    alert(`로그인 요청:\nEmail: ${email}\n\n(실제 구현은 Phase 4에서 진행됩니다)`)

    // 성공 시 모달 닫기
    // this.close()
  }

  // 입력 필드 초기화
  clearFields() {
    if (this.hasSignupNicknameTarget) {
      this.signupNicknameTarget.value = ""
    }
    if (this.hasSignupEmailTarget) {
      this.signupEmailTarget.value = ""
    }
    if (this.hasSigninEmailTarget) {
      this.signinEmailTarget.value = ""
    }
  }
}

import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = [
    "modal",
    "overlay",
    "input",
    "results",
    "searchIcon",
    "clearButton",
    "searchBox"
  ]
  static values = {
    debounce: { type: Number, default: 300 }
  }

  connect() {
    console.log("🔍 Search controller connected")
    console.log("📍 Targets:", {
      modal: this.hasModalTarget,
      overlay: this.hasOverlayTarget,
      input: this.hasInputTarget,
      results: this.hasResultsTarget,
      searchIcon: this.hasSearchIconTarget,
      clearButton: this.hasClearButtonTarget,
      searchBox: this.hasSearchBoxTarget
    })
    this.authors = [] // 저자 목록 캐시
    this.categories = [] // 카테고리 목록 캐시
    this.posts = [] // 포스트 목록 캐시
    this.postsData = null // 전체 포스트 데이터 캐시
    this.loadAllData() // 한 번에 모든 데이터 로드

    // #search-root 요소 참조 저장
    this.rootElement = document.getElementById("search-root")
  }

  disconnect() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)

      console.log("🔍 Search controller disconnected")

      // 모달 CSS 제거
      this.unloadModalCSS()
    }
  }

  // 모달 전용 CSS 로드
  loadModalCSS() {
    // 이미 로드되어 있는지 확인
    if (document.getElementById("search-modal-css")) {
      console.log("✅ Search Modal CSS already loaded")
      return
    }

    console.log("📦 Loading search modal CSS...")

    const style = document.createElement("style")
    style.id = "search-modal-css"
    style.textContent = `
      *,
      :after,
      :before {
        --tw-border-spacing-x: 0;
        --tw-border-spacing-y: 0;
        --tw-translate-x: 0;
        --tw-translate-y: 0;
        --tw-rotate: 0;
        --tw-skew-x: 0;
        --tw-skew-y: 0;
        --tw-scale-x: 1;
        --tw-scale-y: 1;
        --tw-pan-x: ;
        --tw-pan-y: ;
        --tw-pinch-zoom: ;
        --tw-scroll-snap-strictness: proximity;
        --tw-gradient-from-position: ;
        --tw-gradient-via-position: ;
        --tw-gradient-to-position: ;
        --tw-ordinal: ;
        --tw-slashed-zero: ;
        --tw-numeric-figure: ;
        --tw-numeric-spacing: ;
        --tw-numeric-fraction: ;
        --tw-ring-inset: ;
        --tw-ring-offset-width: 0px;
        --tw-ring-offset-color: #fff;
        --tw-ring-color: rgba(59, 130, 246, 0.5);
        --tw-ring-offset-shadow: 0 0 transparent;
        --tw-ring-shadow: 0 0 transparent;
        --tw-shadow: 0 0 transparent;
        --tw-shadow-colored: 0 0 transparent;
        --tw-blur: ;
        --tw-brightness: ;
        --tw-contrast: ;
        --tw-grayscale: ;
        --tw-hue-rotate: ;
        --tw-invert: ;
        --tw-saturate: ;
        --tw-sepia: ;
        --tw-drop-shadow: ;
        --tw-backdrop-blur: ;
        --tw-backdrop-brightness: ;
        --tw-backdrop-contrast: ;
        --tw-backdrop-grayscale: ;
        --tw-backdrop-hue-rotate: ;
        --tw-backdrop-invert: ;
        --tw-backdrop-opacity: ;
        --tw-backdrop-saturate: ;
        --tw-backdrop-sepia: ;
        --tw-contain-size: ;
        --tw-contain-layout: ;
        --tw-contain-paint: ;
        --tw-contain-style:
      }

      ::backdrop {
        --tw-border-spacing-x: 0;
        --tw-border-spacing-y: 0;
        --tw-translate-x: 0;
        --tw-translate-y: 0;
        --tw-rotate: 0;
        --tw-skew-x: 0;
        --tw-skew-y: 0;
        --tw-scale-x: 1;
        --tw-scale-y: 1;
        --tw-pan-x: ;
        --tw-pan-y: ;
        --tw-pinch-zoom: ;
        --tw-scroll-snap-strictness: proximity;
        --tw-gradient-from-position: ;
        --tw-gradient-via-position: ;
        --tw-gradient-to-position: ;
        --tw-ordinal: ;
        --tw-slashed-zero: ;
        --tw-numeric-figure: ;
        --tw-numeric-spacing: ;
        --tw-numeric-fraction: ;
        --tw-ring-inset: ;
        --tw-ring-offset-width: 0px;
        --tw-ring-offset-color: #fff;
        --tw-ring-color: rgba(59, 130, 246, 0.5);
        --tw-ring-offset-shadow: 0 0 transparent;
        --tw-ring-shadow: 0 0 transparent;
        --tw-shadow: 0 0 transparent;
        --tw-shadow-colored: 0 0 transparent;
        --tw-blur: ;
        --tw-brightness: ;
        --tw-contrast: ;
        --tw-grayscale: ;
        --tw-hue-rotate: ;
        --tw-invert: ;
        --tw-saturate: ;
        --tw-sepia: ;
        --tw-drop-shadow: ;
        --tw-backdrop-blur: ;
        --tw-backdrop-brightness: ;
        --tw-backdrop-contrast: ;
        --tw-backdrop-grayscale: ;
        --tw-backdrop-hue-rotate: ;
        --tw-backdrop-invert: ;
        --tw-backdrop-opacity: ;
        --tw-backdrop-saturate: ;
        --tw-backdrop-sepia: ;
        --tw-contain-size: ;
        --tw-contain-layout: ;
        --tw-contain-paint: ;
        --tw-contain-style:
      }

      /*! tailwindcss v3.4.17 | MIT License | https://tailwindcss.com*/
      *,
      :after,
      :before {
        box-sizing: border-box;
        border: 0 solid #e5e7eb
      }

      :host,
      html {
        line-height: 1.5;
        -webkit-text-size-adjust: 100%;
        tab-size: 4;
        font-family: ui-sans-serif, system-ui, sans-serif, Apple Color Emoji, Segoe UI Emoji, Segoe UI Symbol, Noto Color Emoji;
        font-feature-settings: normal;
        font-variation-settings: normal;
        -webkit-tap-highlight-color: transparent
      }

      body {
        margin: 0;
        line-height: inherit
      }

      hr {
        height: 0;
        color: inherit;
        border-top-width: 1px
      }

      abbr:where([title]) {
        -webkit-text-decoration: underline dotted;
        text-decoration: underline dotted
      }

      h1,
      h2,
      h3,
      h4,
      h5,
      h6 {
        font-size: inherit;
        font-weight: inherit
      }

      a {
        color: inherit;
        text-decoration: inherit
      }

      b,
      strong {
        font-weight: bolder
      }

      code,
      kbd,
      pre,
      samp {
        font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, Liberation Mono, Courier New, monospace;
        font-feature-settings: normal;
        font-variation-settings: normal;
        font-size: 1em
      }

      small {
        font-size: 80%
      }

      sub,
      sup {
        font-size: 75%;
        line-height: 0;
        position: relative;
        vertical-align: baseline
      }

      sub {
        bottom: -.25em
      }

      sup {
        top: -.5em
      }

      table {
        text-indent: 0;
        border-color: inherit;
        border-collapse: collapse
      }

      button,
      input,
      optgroup,
      select,
      textarea {
        font-family: inherit;
        font-feature-settings: inherit;
        font-variation-settings: inherit;
        font-size: 100%;
        font-weight: inherit;
        line-height: inherit;
        letter-spacing: inherit;
        color: inherit;
        margin: 0;
        padding: 0
      }

      button,
      select {
        text-transform: none
      }

      button,
      input:where([type=button]),
      input:where([type=reset]),
      input:where([type=submit]) {
        -webkit-appearance: button;
        background-color: transparent;
        background-image: none
      }

      :-moz-focusring {
        outline: auto
      }

      :-moz-ui-invalid {
        box-shadow: none
      }

      progress {
        vertical-align: baseline
      }

      ::-webkit-inner-spin-button,
      ::-webkit-outer-spin-button {
        height: auto
      }

      [type=search] {
        -webkit-appearance: textfield;
        outline-offset: -2px
      }

      ::-webkit-search-decoration {
        -webkit-appearance: none
      }

      ::-webkit-file-upload-button {
        -webkit-appearance: button;
        font: inherit
      }

      summary {
        display: list-item
      }

      blockquote,
      dd,
      dl,
      figure,
      h1,
      h2,
      h3,
      h4,
      h5,
      h6,
      hr,
      p,
      pre {
        margin: 0
      }

      fieldset {
        margin: 0
      }

      fieldset,
      legend {
        padding: 0
      }

      menu,
      ol,
      ul {
        list-style: none;
        margin: 0;
        padding: 0
      }

      dialog {
        padding: 0
      }

      textarea {
        resize: vertical
      }

      input::placeholder,
      textarea::placeholder {
        opacity: 1;
        color: #9ca3af
      }

      [role=button],
      button {
        cursor: pointer
      }

      :disabled {
        cursor: default
      }

      audio,
      canvas,
      embed,
      iframe,
      img,
      object,
      svg,
      video {
        display: block;
        vertical-align: middle
      }

      img,
      video {
        max-width: 100%;
        height: auto
      }

      [hidden]:where(:not([hidden=until-found])) {
        display: none
      }

      .static {
        position: static
      }

      .fixed {
        position: fixed
      }

      .absolute {
        position: absolute
      }

      .relative {
        position: relative
      }

      .bottom-0 {
        bottom: 0
      }

      .left-0 {
        left: 0
      }

      .right-0 {
        right: 0
      }

      .top-0 {
        top: 0
      }

      .z-0 {
        z-index: 0
      }

      .z-10 {
        z-index: 10
      }

      .z-50 {
        z-index: 50
      }

      .m-auto {
        margin: auto
      }

      .-mx-4 {
        margin-left: -1.6rem;
        margin-right: -1.6rem
      }

      .-my-5 {
        margin-top: -2rem;
        margin-bottom: -2rem
      }

      .my-3 {
        margin-top: 1.2rem;
        margin-bottom: 1.2rem
      }

      .-mb-\\[1px\\] {
        margin-bottom: -1px
      }

      .-ms-3 {
        margin-inline-start: -1.2rem
      }

      .-mt-\\[1px\\] {
        margin-top: -1px
      }

      .mb-0 {
        margin-bottom: 0
      }

      .mb-1 {
        margin-bottom: .4rem
      }

      .me-2 {
        margin-inline-end: .8rem
      }

      .me-3 {
        margin-inline-end: 1.2rem
      }

      .ms-3 {
        margin-inline-start: 1.2rem
      }

      .mt-0 {
        margin-top: 0
      }

      .block {
        display: block
      }

      .flex {
        display: flex
      }

      .hidden {
        display: none
      }

      .h-4 {
        height: 1.6rem
      }

      .h-7 {
        height: 2.8rem
      }

      .h-\\[1\\.1rem\\] {
        height: 1.1rem
      }

      .h-screen {
        height: 100vh
      }

      .max-h-\\[calc\\(100vh-172px\\)\\] {
        max-height: calc(100vh - 172px)
      }

      .w-4 {
        width: 1.6rem
      }

      .w-7 {
        width: 2.8rem
      }

      .w-\\[1\\.1rem\\] {
        width: 1.1rem
      }

      .w-full {
        width: 100%
      }

      .w-screen {
        width: 100vw
      }

      .max-w-\\[95vw\\] {
        max-width: 95vw
      }

      .shrink-0 {
        flex-shrink: 0
      }

      .grow {
        flex-grow: 1
      }

      @keyframes fadein {
        0% {
          opacity: 0
        }

        to {
          opacity: 1
        }
      }

      .animate-fadein {
        animation: fadein .15s
      }

      @keyframes popup {
        0% {
          transform: translateY(-20px);
          opacity: 0
        }

        1% {
          transform: translateY(20px);
          opacity: 0
        }

        to {
          transform: translateY(0);
          opacity: 1
        }
      }

      .animate-popup {
        animation: popup .15s ease
      }

      .cursor-pointer {
        cursor: pointer
      }

      .items-center {
        align-items: center
      }

      .justify-center {
        justify-content: center
      }

      .overflow-y-auto {
        overflow-y: auto
      }

      .truncate {
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap
      }

      .rounded {
        border-radius: .4rem
      }

      .rounded-full {
        border-radius: 9999px
      }

      .rounded-lg {
        border-radius: .8rem
      }

      .rounded-t-lg {
        border-top-left-radius: .8rem;
        border-top-right-radius: .8rem
      }

      .border {
        border-width: 1px
      }

      .border-t {
        border-top-width: 1px
      }

      .border-gray-200 {
        --tw-border-opacity: 1;
        border-color: rgb(229 231 235/var(--tw-border-opacity, 1))
      }

      .border-neutral-200 {
        --tw-border-opacity: 1;
        border-color: rgb(229 229 229/var(--tw-border-opacity, 1))
      }

      .bg-neutral-100 {
        --tw-bg-opacity: 1;
        background-color: rgb(245 245 245/var(--tw-bg-opacity, 1))
      }

      .bg-neutral-200 {
        --tw-bg-opacity: 1;
        background-color: rgb(229 229 229/var(--tw-bg-opacity, 1))
      }

      .bg-neutral-300 {
        --tw-bg-opacity: 1;
        background-color: rgb(212 212 212/var(--tw-bg-opacity, 1))
      }

      .bg-white {
        --tw-bg-opacity: 1;
        background-color: rgb(255 255 255/var(--tw-bg-opacity, 1))
      }

      .bg-gradient-to-br {
        background-image: linear-gradient(to bottom right, var(--tw-gradient-stops))
      }

      .from-\\[rgba\\(0\\2c 0\\2c 0\\2c 0\\.2\\)\\] {
        --tw-gradient-from:rgba(0,0,0,0.2) var(--tw-gradient-from-position);
        --tw-gradient-to:transparent var(--tw-gradient-to-position);
        --tw-gradient-stops:var(--tw-gradient-from),var(--tw-gradient-to)
      }
      .to-\\[rgba\\(0\\2c 0\\2c 0\\2c 0\\.1\\)\\] {
        --tw-gradient-to:rgba(0,0,0,0.1) var(--tw-gradient-to-position)
      }

      .object-cover {
        object-fit: cover
      }

      .p-\\[1rem\\] {
        padding: 1rem
      }

      .px-4 {
        padding-left: 1.6rem;
        padding-right: 1.6rem
      }

      .px-7 {
        padding-left: 2.8rem;
        padding-right: 2.8rem
      }

      .py-3 {
        padding-top: 1.2rem;
        padding-bottom: 1.2rem
      }

      .py-4 {
        padding-top: 1.6rem;
        padding-bottom: 1.6rem
      }

      .py-5 {
        padding-top: 2rem;
        padding-bottom: 2rem
      }

      .py-\\[1rem\\] {
        padding-top: 1rem;
        padding-bottom: 1rem
      }

      .ps-3 {
        padding-inline-start: 1.2rem
      }

      .pt-20 {
        padding-top: 8rem
      }

      .text-\\[1\\.65rem\\] {
        font-size: 1.65rem
      }

      .text-sm {
        font-size: 1.4rem
      }

      .text-xs {
        font-size: 1.2rem
      }

      .font-bold {
        font-weight: 700
      }

      .font-medium {
        font-weight: 500
      }

      .font-semibold {
        font-weight: 600
      }

      .uppercase {
        text-transform: uppercase
      }

      .leading-normal {
        line-height: 1.5
      }

      .leading-tight {
        line-height: 1.25
      }

      .tracking-wide {
        letter-spacing: .025em
      }

      .text-neutral-400 {
        --tw-text-opacity: 1;
        color: rgb(163 163 163/var(--tw-text-opacity, 1))
      }

      .text-neutral-500 {
        --tw-text-opacity: 1;
        color: rgb(115 115 115/var(--tw-text-opacity, 1))
      }

      .text-neutral-800 {
        --tw-text-opacity: 1;
        color: rgb(38 38 38/var(--tw-text-opacity, 1))
      }

      .text-neutral-900 {
        --tw-text-opacity: 1;
        color: rgb(23 23 23/var(--tw-text-opacity, 1))
      }

      .antialiased {
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale
      }

      .shadow {
        --tw-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px -1px rgba(0, 0, 0, 0.1);
        --tw-shadow-colored: 0 1px 3px 0 var(--tw-shadow-color), 0 1px 2px -1px var(--tw-shadow-color)
      }

      .shadow,
      .shadow-xl {
        box-shadow: var(--tw-ring-offset-shadow, 0 0 transparent), var(--tw-ring-shadow, 0 0 transparent), var(--tw-shadow)
      }

      .shadow-xl {
        --tw-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1);
        --tw-shadow-colored: 0 20px 25px -5px var(--tw-shadow-color), 0 8px 10px -6px var(--tw-shadow-color)
      }

      .outline-none {
        outline: 2px solid transparent;
        outline-offset: 2px
      }

      .outline {
        outline-style: solid
      }

      .filter {
        filter: var(--tw-blur) var(--tw-brightness) var(--tw-contrast) var(--tw-grayscale) var(--tw-hue-rotate) var(--tw-invert) var(--tw-saturate) var(--tw-sepia) var(--tw-drop-shadow)
      }

      .backdrop-blur-\\[2px\\] {
        --tw-backdrop-blur: blur(2px);
        -webkit-backdrop-filter: var(--tw-backdrop-blur) var(--tw-backdrop-brightness) var(--tw-backdrop-contrast) var(--tw-backdrop-grayscale) var(--tw-backdrop-hue-rotate) var(--tw-backdrop-invert) var(--tw-backdrop-opacity) var(--tw-backdrop-saturate) var(--tw-backdrop-sepia);
        backdrop-filter: var(--tw-backdrop-blur) var(--tw-backdrop-brightness) var(--tw-backdrop-contrast) var(--tw-backdrop-grayscale) var(--tw-backdrop-hue-rotate) var(--tw-backdrop-invert) var(--tw-backdrop-opacity) var(--tw-backdrop-saturate) var(--tw-backdrop-sepia)
      }

      .transition {
        transition-property: color, background-color, border-color, text-decoration-color, fill, stroke, opacity, box-shadow, transform, filter, -webkit-backdrop-filter;
        transition-property: color, background-color, border-color, text-decoration-color, fill, stroke, opacity, box-shadow, transform, filter, backdrop-filter;
        transition-property: color, background-color, border-color, text-decoration-color, fill, stroke, opacity, box-shadow, transform, filter, backdrop-filter, -webkit-backdrop-filter;
        transition-timing-function: cubic-bezier(.4, 0, .2, 1)
      }

      .duration-150,
      .transition {
        transition-duration: .15s
      }

      html {
        font-size: 62.5%
      }

      body {
        font-size: 1.5rem
      }

      .ghost-display {
        display: block !important
      }

      .placeholder\\:text-gray-400::placeholder {
        --tw-text-opacity: 1;
        color: rgb(156 163 175/var(--tw-text-opacity, 1))
      }

      .hover\\:border-neutral-300:hover {
        --tw-border-opacity: 1;
        border-color: rgb(212 212 212/var(--tw-border-opacity, 1))
      }

      .hover\\:text-black:hover {
        --tw-text-opacity: 1;
        color: rgb(0 0 0/var(--tw-text-opacity, 1))
      }

      .hover\\:text-neutral-500:hover {
        --tw-text-opacity: 1;
        color: rgb(115 115 115/var(--tw-text-opacity, 1))
      }

      .focus-visible\\:outline-none:focus-visible {
        outline: 2px solid transparent;
        outline-offset: 2px
      }

      @media (min-width:640px) {
        .sm\\:-mx-7 {
          margin-left: -2.8rem;
          margin-right: -2.8rem
        }

        .sm\\:hidden {
          display: none
        }

        .sm\\:max-h-\\[70vh\\] {
          max-height: 70vh
        }

        .sm\\:max-w-lg {
          max-width: 51.2rem
        }

        .sm\\:px-7 {
          padding-left: 2.8rem;
          padding-right: 2.8rem
        }
      }

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

      @media (max-width: 480px) {
        .gh-portal-popup-background {
          animation: none;
        }
      }
    `

    // CSS 로드 완료 이벤트
    style.onload = () => {
      console.log("✅ Search Modal CSS loaded successfully")
    }

    style.onerror = () => {
      console.error("❌ Failed to load search modal CSS")
    }

    document.head.appendChild(style)
  }

  // 모달 CSS 제거
  unloadModalCSS() {
    const link = document.getElementById("search-modal-css")
    if (link) {
      console.log("🗑️ Unloading Search modal CSS...")
      link.remove()
      console.log("✅ Search Modal CSS unloaded")
    }
  }

  // 검색 결과 클릭 시 페이지 이동
  navigateResult(event) {
    const url = event.params.url

    console.log("🔗 Navigating to:", url)

    if (url) {
      // Turbo를 사용하여 페이지 이동 (SPA 방식)
      Turbo.visit(url)
      // 모달 닫기
      this.close()
    }
  }

  // 모든 데이터를 한 번에 로드 (authors, categories, posts)
  async loadAllData() {
    try {
      console.log("📡 Fetching posts data...")
      const response = await fetch('/posts.json')
      if (!response.ok) throw new Error('Failed to load posts')

      const data = await response.json()
      const posts = data.posts || []
      this.postsData = posts // 캐시 저장

      // 저자 목록 추출
      const uniqueAuthors = [...new Set(posts.map(post => post.author_name))]
      this.authors = uniqueAuthors.map(name => {
        const findAuthor = posts.find(p => p.author_name === name)
        return {
          name: name,
          avatar_url: findAuthor?.author_avatar_url || null
        }
      })

      // 카테고리 목록 추출
      const uniqueCategories = [...new Set(posts.map(post => post.category))]
      this.categories = uniqueCategories.map(name => {
        return {
          name: name,
        }
      })

      // 포스트 목록 추출
      const uniquePosts = [...new Set(posts.map(post => post.title))]
      this.posts = uniquePosts.map(name => {
        const findPost = posts.find(p => p.title === name)
        return {
          name: name,
          excerpt: findPost.excerpt,
          slug: findPost.slug
        }
      })

      console.log("✅ All search data loaded:", {
        authors: this.authors.length,
        categories: this.categories.length,
        posts: this.posts.length
      })
    } catch (error) {
      console.error("❌ Failed to load search data:", error)
      this.authors = []
      this.categories = []
      this.posts = []
    }
  }

  // 검색 모달 열기
  open() {
    console.log("🚀 Opening search modal")

    // 모달 CSS 로드 (열 때마다)
    this.loadModalCSS()

    // Body 스크롤 방지
    document.body.style.overflow = "hidden"

    // #search-root 표시
    if (this.rootElement) {
      this.rootElement.style.display = "block"
    }

    // 입력창 포커스
    setTimeout(() => {
      this.inputTarget.focus()
    }, 100)

    console.log("✅ Search Modal opened")
  }

  // 검색 모달 닫기
  close() {
    console.log("🔒 Closing search modal")

    // Body 스타일 복원
    document.body.style.overflow = ""

    // #search-root 숨김
    if (this.rootElement) {
      this.rootElement.style.display = "none"
    }

    // 검색 초기화
    this.clearSearch()

    // 모달 CSS 제거 (닫을 때마다)
    this.unloadModalCSS()
  }

  // 이벤트 전파 중단 (모달 컨테이너 내부 클릭 시)
  // 모달 안쪽을 클릭해도 모달이 닫히지 않도록 함
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

  // 검색어 클리어
  clearSearch() {
    this.inputTarget.value = ""
    this.resultsTarget.innerHTML = ""
    this.toggleClearButton(false)
  }

  // 입력 시 debounce 처리 후 검색
  search() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }

    this.debounceTimer = setTimeout(() => {
      this.performSearch()
    }, this.debounceValue)
  }

  // 실제 검색 수행 (Author만 검색)
  performSearch() {
    const query = this.inputTarget.value.trim()

    // 검색어가 비었으면 결과 초기화
    if (query.length === 0) {
      this.resultsTarget.innerHTML = ""
      this.toggleClearButton(false)
      this.toggleSearchBoxShadow(false)
      return
    }

    // 검색어가 있으면 shadow 추가
    this.toggleSearchBoxShadow(true)

    // Clear 버튼 표시
    this.toggleClearButton(true)

    // Author 이름으로 검색 (첫 글자가 일치하는 경우만)
    const matchedAuthors = this.authors.filter(author =>
      author.name.toLowerCase().startsWith(query.toLowerCase())
    )

    // Category 이름으로 검색 (첫 글자가 일치하는 경우만)
    const matchedCategories = this.categories.filter(category =>
      category.name.toLowerCase().startsWith(query.toLowerCase())
    )

    // Post 제목으로 검색 (부분 문자열 일치)
    const matchedPosts = this.posts.filter(post =>
      post.name.toLowerCase().includes(query.toLowerCase())
    )

    // 검색 결과 표시 (검색어도 함께 전달)
    this.displayResults(matchedAuthors, matchedCategories, matchedPosts, query)
  }

  // 검색 결과 표시
  displayResults(authors, categories, posts, query = '') {
    // 결과가 없을 때 "No matches found" 표시
    if (authors.length === 0 && categories.length === 0 && posts.length === 0) {
      this.resultsTarget.innerHTML = `
        <div class="py-4 px-7">
          <p class="text-[1.65rem] text-neutral-400 leading-normal">
            No matches found
          </p>
        </div>
      `
      return
    }

    // 기존 이벤트 리스너 제거 (중복 방지)
    this.cleanupEventListeners()

    // 각 섹션을 개별적으로 생성 (결과가 있는 섹션만)
    let htmlSections = []

    // 첫 번째 결과인지 추적
    let isFirstResult = true

    // Authors 섹션 (결과가 있을 때만)
    if (authors.length > 0) {
      htmlSections.push(`
        <div class="border-t border-neutral-200 py-3 px-4 sm:px-7">
          <h1 class="uppercase text-xs text-neutral-400 font-semibold mb-1 tracking-wide">Authors</h1>
          ${authors.map((author, index) => `
            <div data-action="click->search#navigateResult"
                 data-search-url-param="/author/${encodeURIComponent(author.name.toLowerCase())}"
                 class="py-[1rem] -mx-4 sm:-mx-7 px-4 sm:px-7 cursor-pointer flex items-center${index === 0 && isFirstResult ? ' bg-neutral-100' : ''}">
              ${this.getAvatarHTML(author)}
              <h2 class="text-[1.65rem] leading-tight text-neutral-900 truncate">${this.escapeHtml(author.name)}</h2>
            </div>
          `).join('')}
        </div>
      `)
      isFirstResult = false
    }

    // Tags(Category) 섹션 (결과가 있을 때만)
    if (categories.length > 0) {
      htmlSections.push(`
        <div class="border-t border-gray-200 py-3 px-4 sm:px-7">
          <h1 class="uppercase text-xs text-neutral-400 font-semibold mb-1 tracking-wide">Tags</h1>
          ${categories.map((category, index) => `
            <div data-action="click->search#navigateResult"
                 data-search-url-param="/category/${encodeURIComponent(category.name.toLowerCase())}"
                 class="flex items-center py-3 -mx-4 sm:-mx-7 px-4 sm:px-7 cursor-pointer${index === 0 && isFirstResult ? ' bg-neutral-100' : ''}">
              <p class="me-2 text-sm font-bold text-neutral-400">#</p>
              <h2 class="text-[1.65rem] leading-tight text-neutral-900 truncate">${this.escapeHtml(category.name)}</h2>
            </div>
          `).join('')}
        </div>
      `)
      isFirstResult = false
    }

    // Posts 섹션 (결과가 있을 때만)
    if (posts.length > 0) {
      htmlSections.push(`
        <div class="border-t border-neutral-200 py-3 px-4 sm:px-7">
          <h1 class="uppercase text-xs text-neutral-400 font-semibold mb-1 tracking-wide">Posts</h1>
          ${posts.map((post, index) => `
            <div class="search-result-item py-3 -mx-4 sm:-mx-7 px-4 sm:px-7 cursor-pointer${index === 0 && isFirstResult ? ' bg-neutral-100' : ''}"
                 data-action="click->search#navigateResult"
                 data-search-url-param="/${this.escapeHtml(post.slug)}"
                 data-slug="${this.escapeHtml(post.slug)}"
                 data-type="post">
              <h2 class="text-[1.65rem] leading-tight text-neutral-800">
                ${this.highlightMatch(post.name, query)}
              </h2>
              <p class="text-neutral-400 leading-normal text-sm mt-0 mb-0 truncate">
                ${this.escapeHtml(post.excerpt)}
              </p>
            </div>
          `).join('')}
        </div>
      `)
    }

    // 모든 섹션 결합
    this.resultsTarget.innerHTML = htmlSections.join('')

    // 동적 hover 효과 설정
    this.setupHoverEffects()
  }

  // Avatar HTML 생성 (이미지 또는 minidenticon)
  getAvatarHTML(author) {
    // minidenticon SVG 생성 (fallback)
    const identicon = window.minidenticonSvg ?
      window.minidenticonSvg() :
      `<minidenticon-svg username="${author.name}"></minidenticon-svg>`

    // avatar_url이 있는 경우
    if (author.avatar_url) {
      return `
      <img class="rounded-full bg-neutral-300 w-7 h-7 me-2 object-cover"
        src="${this.escapeHtml(author.avatar_url)}"
        alt="${this.escapeHtml(author.name)}">
      `
    }

    // 기본값: minidenticon 표시
    return identicon
  }

  // Clear 버튼 토글
  toggleClearButton(show) {
    if (show) {
      this.searchIconTarget.classList.add("hidden")
      this.clearButtonTarget.classList.remove("hidden")
    } else {
      this.searchIconTarget.classList.remove("hidden")
      this.clearButtonTarget.classList.add("hidden")
    }
  }

  // 검색 박스 shadow 토글
  toggleSearchBoxShadow(show) {
    if (show) {
      this.searchBoxTarget.classList.add("shadow")
    } else {
      this.searchBoxTarget.classList.remove("shadow")
    }
  }

  // HTML 이스케이프 (XSS 방지)
  escapeHtml(text) {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  // 검색어 하이라이트 (일치하는 부분을 bold로 표시)
  highlightMatch(text, query) {
    // 검색어가 비어있으면 첫 글자만 bold 처리 (기본 동작)
    if (!query || query.trim().length === 0) {
      return `<span class="font-bold text-neutral-900">${this.escapeHtml(text.charAt(0).toUpperCase())}</span>${this.escapeHtml(text.slice(1))}`
    }

    // 대소문자 구분 없이 검색어 위치 찾기
    const lowerText = text.toLowerCase()
    const lowerQuery = query.toLowerCase().trim()
    const index = lowerText.indexOf(lowerQuery)

    // 검색어가 텍스트에 포함되지 않으면 첫 글자만 bold 처리
    if (index === -1) {
      return `<span class="font-bold text-neutral-900">${this.escapeHtml(text.charAt(0).toUpperCase())}</span>${this.escapeHtml(text.slice(1))}`
    }

    // 검색어 부분을 bold로 강조
    const before = text.slice(0, index)
    const match = text.slice(index, index + lowerQuery.length)
    const after = text.slice(index + lowerQuery.length)

    return `${this.escapeHtml(before)}<span class="font-bold text-neutral-900">${this.escapeHtml(match)}</span>${this.escapeHtml(after)}`
  }

  // 이벤트 리스너 정리
  cleanupEventListeners() {
    // 저장된 리스너가 있으면 제거
    if (this.hoverHandler) {
      this.resultsTarget.removeEventListener('mouseenter', this.hoverHandler, true)
      this.resultsTarget.removeEventListener('mouseleave', this.hoverHandler, true)
    }
  }

  // 동적 hover 효과 설정
  setupHoverEffects() {
    // 이벤트 위임: resultsTarget에 리스너 추가
    this.hoverHandler = (event) => {
      const target = event.target.closest('div[data-action*="navigateResult"]')

      if (!target) return

      if (event.type === 'mouseenter') {
        // 기존 hover된 요소에서 배경색 제거
        this.resultsTarget.querySelectorAll('.bg-neutral-100').forEach(el => {
          el.classList.remove('bg-neutral-100')
        })
        // 현재 요소에 배경색 추가
        target.classList.add('bg-neutral-100')
      } else if (event.type === 'mouseleave') {
        // 마우스가 떠날 때 배경색 제거
        target.classList.remove('bg-neutral-100')
      }
    }

    // mouseenter와 mouseleave는 버블링되지 않으므로 capture phase 사용
    this.resultsTarget.addEventListener('mouseenter', this.hoverHandler, true)
    this.resultsTarget.addEventListener('mouseleave', this.hoverHandler, true)
  }

  // ===== Global Controller Helper 메서드 =====
  // Global controller 인스턴스 가져오기
  getGlobalController() {
    const globalController = this.application.getControllerForElementAndIdentifier(
      document.body,
      'global'
    )

    if (!globalController) {
      console.error("❌ Global controller not found")
    }

    return globalController
  }

  // [호출] 키보드 단축키 처리 (Escape)
  handleGlobalKeyboard(event) {
    const globalController = this.application.getControllerForElementAndIdentifier(
      document.body,
      'global'
    )

    if (globalController) {
      // Global controller의 handleKeyboard 호출
      globalController.handleKeyboard(event, {
        // onEscape: Escape 키를 눌렀을 때 실행할 함수
        onEscape: () => this.close(),
        // condition: 키 이벤트를 처리할 조건 (모달이 열려있는지 확인)
        condition: () => this.isOpen()
      })
    } else {
      console.error("❌ Global controller not found")
    }
  }
}

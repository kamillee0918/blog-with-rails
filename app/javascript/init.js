// ========================================
// TinyMCE Editor
// ========================================

// TinyMCE 초기화 모듈
function initTinyMCE() {
  const textarea = document.getElementById("post_content");
  if (!textarea) return null;

  // 이미 초기화되었는지 확인 (중복 방지)
  if (textarea.dataset.tinymceInitialized) return null;
  textarea.dataset.tinymceInitialized = "true";

  // 기존 TinyMCE 인스턴스 제거 (Turbo 네비게이션 대응)
  if (typeof tinymce !== "undefined") {
    tinymce.remove("#post_content");
  }

  // CSRF 토큰 가져오기
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

  tinymce.init({
    selector: "#post_content",
    height: 500,
    plugins: [
      "advlist",
      "autolink",
      "lists",
      "link",
      "image",
      "charmap",
      "preview",
      "anchor",
      "searchreplace",
      "visualblocks",
      "code",
      "fullscreen",
      "insertdatetime",
      "media",
      "table",
      "help",
      "wordcount",
      "codesample",
    ],
    toolbar:
      "undo redo | blocks | " +
      "bold italic forecolor | alignleft aligncenter " +
      "alignright alignjustify | bullist numlist outdent indent | " +
      "table image media | codesample | removeformat | code | help",
    content_style:
      'body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; font-size: 16px; }',

    // ========================================
    // Code Sample 플러그인 설정 (PrismJS 연동)
    // ========================================
    codesample_global_prismjs: true,
    codesample_languages: [
      { text: "HTML/XML", value: "markup" },
      { text: "JavaScript", value: "javascript" },
      { text: "CSS", value: "css" },
      { text: "Ruby", value: "ruby" },
      { text: "ERB (Ruby Template)", value: "erb" },
      { text: "Python", value: "python" },
      { text: "Java", value: "java" },
      { text: "Bash/Shell", value: "bash" },
      { text: "SQL", value: "sql" },
      { text: "JSON", value: "json" },
      { text: "YAML", value: "yaml" },
      { text: "Markdown", value: "markdown" },
      { text: "Plain Text", value: "plain" },
    ],

    // ========================================
    // 콘텐츠 보호 설정 (ERB 태그 등 특수 구문 보호)
    // ========================================
    // ERB 템플릿 태그 (<%, %>, <%=, <%#)가 제거되지 않도록 보호
    protect: [
      /<%[\s\S]*?%>/g, // ERB 태그 보호
      /<\?[\s\S]*?\?>/g, // PHP 태그 보호 (필요시)
    ],
    // 인코딩 설정: HTML 엔티티로 자동 변환 방지
    entity_encoding: "raw",
    // 유효한 요소 확장 (pre, code 태그 및 class 속성 허용)
    extended_valid_elements:
      "pre[class],code[class],script[*],template[*],turbo-stream[action|target]",
    // 커스텀 요소 허용
    custom_elements: "turbo-stream,template",

    // URL 설정: 절대 경로 사용 (이미지 404 오류 방지)
    relative_urls: false,
    remove_script_host: false,
    document_base_url: window.location.origin + "/",

    // CORS: Tiny Cloud 리소스(plugins/skins/css 등) 로딩 시 crossOrigin/referrer 정책 적용
    // https://www.tiny.cloud/docs/tinymce/latest/tinymce-and-cors/
    referrer_policy: "origin",
    crossorigin: (url, resourceType) => {
      try {
        const parsed = new URL(url, window.location.origin);
        if (parsed.hostname.endsWith("tiny.cloud")) return "anonymous";
      } catch (_) {}
      return undefined;
    },

    link_attributes_postprocess: (attrs) => {
      attrs["data-turbo"] = "false";
    },

    // 테이블 기본 설정
    table_default_styles: {
      "border-collapse": "collapse",
      width: "100%",
    },

    // ========================================
    // 이미지 업로드 설정 (드래그 & 드롭 지원)
    // ========================================
    automatic_uploads: true,
    images_upload_url: "/uploads/image",
    images_upload_credentials: true,

    // 이미지 업로드 핸들러 (CSRF 토큰 포함)
    images_upload_handler: function (blobInfo, progress) {
      return new Promise(function (resolve, reject) {
        const formData = new FormData();
        formData.append("file", blobInfo.blob(), blobInfo.filename());

        const xhr = new XMLHttpRequest();
        xhr.open("POST", "/uploads/image");
        xhr.setRequestHeader("X-CSRF-Token", csrfToken);

        xhr.upload.onprogress = function (e) {
          if (e.lengthComputable) {
            progress((e.loaded / e.total) * 100);
          }
        };

        xhr.onload = function () {
          if (xhr.status === 200 || xhr.status === 201) {
            const json = JSON.parse(xhr.responseText);
            if (json.location) {
              resolve(json.location);
            } else {
              reject("Invalid response: " + xhr.responseText);
            }
          } else {
            reject("Upload failed: " + xhr.status);
          }
        };

        xhr.onerror = function () {
          reject("Upload failed due to network error");
        };

        xhr.send(formData);
      });
    },

    // 파일 선택 다이얼로그 설정
    file_picker_types: "image",
    file_picker_callback: function (callback, value, meta) {
      if (meta.filetype === "image") {
        const input = document.createElement("input");
        input.setAttribute("type", "file");
        input.setAttribute("accept", "image/*");
        input.onchange = function () {
          const file = this.files[0];
          const reader = new FileReader();
          reader.onload = function () {
            const id = "blobid" + new Date().getTime();
            const blobCache = tinymce.activeEditor.editorUpload.blobCache;
            const base64 = reader.result.split(",")[1];
            const blobInfo = blobCache.create(id, file, base64);
            blobCache.add(blobInfo);
            callback(blobInfo.blobUri(), { title: file.name });
          };
          reader.readAsDataURL(file);
        };
        input.click();
      }
    },

    // Turbo 호환: 폼 제출 전 에디터 내용 동기화
    setup: function (editor) {
      const ensureTurboFalseLinks = () => {
        const body = editor.getBody();
        if (!body) return;

        body.querySelectorAll("a").forEach((a) => {
          a.setAttribute("data-turbo", "false");
        });
      };

      editor.on("BeforeGetContent", function () {
        ensureTurboFalseLinks();
      });

      editor.on("change", function () {
        ensureTurboFalseLinks();
        editor.save();
      });
    },
  });
}

// ========================================
// Helper Function
// ========================================

// 검색 핸들러
function handleSearchSubmit(event) {
  event.preventDefault();
  const input = document.getElementById("search-input");
  const keyword = input.value.trim();
  if (keyword) {
    window.location.href = "/search/" + encodeURIComponent(keyword);
  }
  return false;
}

// Copy Link 핸들러
function handleCopyLink(event) {
  event.preventDefault();
  const url = window.location.href;

  navigator.clipboard
    .writeText(url)
    .then(() => {
      // 복사 성공 시 알림 표시
      const notification = document.querySelector("[data-share-notification]");
      if (notification) {
        notification.classList.add("is-visible");
        setTimeout(() => {
          notification.classList.remove("is-visible");
        }, 2000);
      }
    })
    .catch((err) => {
      // 폴백: 구형 브라우저 지원
      const textArea = document.createElement("textarea");
      textArea.value = url;
      document.body.appendChild(textArea);
      textArea.select();
      document.execCommand("copy");
      document.body.removeChild(textArea);
    });
}

// 페이지 초기화 함수
function initializePage() {
  // PrismJS: 코드 블록 하이라이팅 적용
  // 동적으로 로드된 콘텐츠 (DB에서 가져온 HTML)에 구문 강조 적용
  if (typeof Prism !== "undefined") {
    Prism.highlightAll();
  }

  // Scroll to top 버튼 설정
  const scrollToTopBtn = document.querySelector("[data-scroll-to-top]");
  if (scrollToTopBtn) {
    // Scroll 이벤트 핸들러
    const handleScroll = () => {
      if (window.pageYOffset > 600) {
        scrollToTopBtn.classList.add("is-active");
      } else {
        scrollToTopBtn.classList.remove("is-active");
      }
    };

    // 기존 이벤트 리스너 제거 후 새로 등록 (중복 방지)
    window.removeEventListener("scroll", handleScroll);
    window.addEventListener("scroll", handleScroll);

    // 초기 상태 설정
    handleScroll();

    // 클릭 이벤트 (이미 등록되어 있으면 중복 방지)
    if (!scrollToTopBtn.hasAttribute("data-initialized")) {
      scrollToTopBtn.addEventListener("click", (e) => {
        e.preventDefault();
        window.scrollTo({
          top: 0,
          behavior: "smooth",
        });
      });
      scrollToTopBtn.setAttribute("data-initialized", "true");
    }
  }

  // Copy Link 버튼 설정
  const copyLinkBtn = document.querySelector(".ts-share-buttons-copy a");
  if (copyLinkBtn && !copyLinkBtn.hasAttribute("data-initialized")) {
    copyLinkBtn.addEventListener("click", handleCopyLink);
    copyLinkBtn.setAttribute("data-initialized", "true");
  }

  // TinyMCE Editor 초기화
  initTinyMCE();
}

// ========================================
// 이벤트 리스너 등록 (중복 방지)
// ========================================

if (!window._initJsLoaded) {
  window._initJsLoaded = true;

  // Turbo 호환: turbo:load 이벤트 사용 (페이지 이동 시에도 동작)
  document.addEventListener("turbo:load", initializePage);

  // 폴백: Turbo가 없는 경우를 위한 DOMContentLoaded
  document.addEventListener("DOMContentLoaded", function () {
    if (!document.documentElement.hasAttribute("data-turbo-loaded")) {
      initializePage();
    }
  });
}

// 전역으로 노출 (inline에서 호출 가능하도록)
window.initTinyMCE = initTinyMCE;
window.handleSearchSubmit = handleSearchSubmit;
window.handleCopyLink = handleCopyLink;

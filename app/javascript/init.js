// ========================================
// Froala Editor 커스텀 버튼
// ========================================

// Froala Editor 초기화 모듈
function initFroalaEditor(selector, options = {}) {
  const element = document.querySelector(selector);
  if (!element) return null;

  const defaultOptions = {
    height: 300
  };

  const mergedOptions = { ...defaultOptions, ...options };

  return new FroalaEditor(selector, mergedOptions);
}

// ========================================
// Helper Function
// ========================================

// 검색 핸들러
function handleSearchSubmit(event) {
  event.preventDefault();
  const input = document.getElementById('search-input');
  const keyword = input.value.trim();
  if (keyword) {
    window.location.href = '/search/' + encodeURIComponent(keyword);
  }
  return false;
}

// Copy Link 핸들러
function handleCopyLink(event) {
  event.preventDefault();
  const url = window.location.href;

  navigator.clipboard.writeText(url).then(() => {
    // 복사 성공 시 알림 표시
    const notification = document.querySelector('[data-share-notification]');
    if (notification) {
      notification.classList.add('is-visible');
      setTimeout(() => {
        notification.classList.remove('is-visible');
      }, 2000);
    }
  }).catch(err => {
    // 폴백: 구형 브라우저 지원
    const textArea = document.createElement('textarea');
    textArea.value = url;
    document.body.appendChild(textArea);
    textArea.select();
    document.execCommand('copy');
    document.body.removeChild(textArea);
  });
}

// 페이지 초기화 함수
function initializePage() {
  // Froala Editor 초기화 (해당 요소가 있을 때만)
  if (document.querySelector('#froala-editor')) {
    window.froalaEditorInstance = initFroalaEditor('#froala-editor');
  }

  // Scroll to top 버튼 설정
  const scrollToTopBtn = document.querySelector('[data-scroll-to-top]');
  if (scrollToTopBtn) {
    // Scroll 이벤트 핸들러
    const handleScroll = () => {
      if (window.pageYOffset > 600) {
        scrollToTopBtn.classList.add('is-active');
      } else {
        scrollToTopBtn.classList.remove('is-active');
      }
    };

    // 기존 이벤트 리스너 제거 후 새로 등록 (중복 방지)
    window.removeEventListener('scroll', handleScroll);
    window.addEventListener('scroll', handleScroll);

    // 초기 상태 설정
    handleScroll();

    // 클릭 이벤트 (이미 등록되어 있으면 중복 방지)
    if (!scrollToTopBtn.hasAttribute('data-initialized')) {
      scrollToTopBtn.addEventListener('click', (e) => {
        e.preventDefault();
        window.scrollTo({
          top: 0,
          behavior: 'smooth',
        });
      });
      scrollToTopBtn.setAttribute('data-initialized', 'true');
    }
  }

  // Copy Link 버튼 설정
  const copyLinkBtn = document.querySelector('.ts-share-buttons-copy a');
  if (copyLinkBtn && !copyLinkBtn.hasAttribute('data-initialized')) {
    copyLinkBtn.addEventListener('click', handleCopyLink);
    copyLinkBtn.setAttribute('data-initialized', 'true');
  }
}

// ========================================
// 이벤트 리스너 등록 (중복 방지)
// ========================================

if (!window._initJsLoaded) {
  window._initJsLoaded = true;

  // Turbo 호환: turbo:load 이벤트 사용 (페이지 이동 시에도 동작)
  document.addEventListener('turbo:load', initializePage);

  // 폴백: Turbo가 없는 경우를 위한 DOMContentLoaded
  document.addEventListener('DOMContentLoaded', function () {
    if (!document.documentElement.hasAttribute('data-turbo-loaded')) {
      initializePage();
    }
  });
}

// 전역으로 노출 (inline에서 호출 가능하도록)
window.initFroalaEditor = initFroalaEditor;
window.handleSearchSubmit = handleSearchSubmit;
window.handleCopyLink = handleCopyLink;

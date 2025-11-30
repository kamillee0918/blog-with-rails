import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search"
export default class extends Controller {
  static targets = ["modal"]

  open() {
    if (this.modalTarget.style.display === "block") return;

    this.fadeInModal();

    // Focus on search input when modal opens
    const input = this.modalTarget.querySelector(".ts-search__input")
    if (input) {
      // Wait for animation to start slightly
      setTimeout(() => input.focus(), 300)
    }
  }

  close() {
    if (this.modalTarget.style.display === "none") return;
    this.fadeOutModal();
  }

  // Close modal when pressing Escape key
  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  // FadeIn modal when opening
  fadeInModal(duration = 300) {
    this.modalTarget.style.opacity = 0;
    this.modalTarget.style.display = "block";
    
    let start = null;
    const animate = (timestamp) => {
      if (!start) start = timestamp;
      const progress = timestamp - start;
      const opacity = Math.min(progress / duration, 1);
      
      this.modalTarget.style.opacity = opacity;
      
      if (progress < duration) {
        requestAnimationFrame(animate);
      }
    };
    requestAnimationFrame(animate);
  }
  
  // FadeOut modal when closin
  fadeOutModal(duration = 300) {
    this.modalTarget.style.opacity = 1;

    let start = null;
    const animate = (timestamp) => {
      if (!start) start = timestamp;
      const progress = timestamp - start;
      const opacity = Math.max(1 - (progress / duration), 0);

      this.modalTarget.style.opacity = opacity;

      if (progress < duration) {
        requestAnimationFrame(animate);
      } else {
        this.modalTarget.style.display = "none";
      }
    };
    requestAnimationFrame(animate);
  }
}

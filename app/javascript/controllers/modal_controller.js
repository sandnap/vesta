import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  connect() {
    // Prevent scrolling on the background when modal is open
    document.body.style.overflow = "hidden"
  }

  disconnect() {
    // Re-enable scrolling when modal is closed
    document.body.style.overflow = "auto"
  }

  closeBackground(event) {
    if (event.target === event.currentTarget) {
      window.history.back()
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      window.history.back()
    }
  }

  close() {
    Turbo.visit(window.location.href, { action: "replace" })
  }
}

import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

// Connects to data-controller="portfolio"
export default class extends Controller {
  static targets = ["select"]

  connect() {
    if (this.hasSelectTarget) {
      this.selectTarget.addEventListener("change", this.handleChange.bind(this))
    }
  }

  handleChange(event) {
    const portfolioId = event.target.value
    if (portfolioId) {
      Turbo.visit(`/portfolios/${portfolioId}`, { action: "advance" })
    } else {
      Turbo.visit("/portfolios", { action: "advance" })
    }
  }
}

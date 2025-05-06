import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="investments-table"
export default class extends Controller {
  static targets = ["row"]
  static values = {
    hideZeroUnits: { type: Boolean, default: false },
  }

  connect() {
    // Load preference from localStorage
    const hideZeroUnits = localStorage.getItem("hideZeroUnits") === "true"
    this.hideZeroUnitsValue = hideZeroUnits
    this.updateVisibility()
  }

  toggle() {
    this.hideZeroUnitsValue = !this.hideZeroUnitsValue
    localStorage.setItem("hideZeroUnits", this.hideZeroUnitsValue)
    this.updateVisibility()
  }

  updateVisibility() {
    this.rowTargets.forEach((row) => {
      const units = parseFloat(row.dataset.units)
      if (units === 0) {
        row.classList.toggle("hidden", this.hideZeroUnitsValue)
      }
    })
  }
}

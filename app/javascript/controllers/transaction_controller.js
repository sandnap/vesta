import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="transaction"
export default class extends Controller {
  static targets = ["units", "unitPrice", "totalValue", "type"]

  connect() {
    this.calculateTotal()
  }

  calculateTotal() {
    const units = parseFloat(this.unitsTarget.value) || 0
    const unitPrice = parseFloat(this.unitPriceTarget.value) || 0
    const total = units * unitPrice

    this.totalValueTarget.textContent = total.toLocaleString("en-US", {
      style: "currency",
      currency: "USD",
    })
  }

  validateUnits() {
    const units = parseFloat(this.unitsTarget.value)
    if (units <= 0) {
      this.unitsTarget.setCustomValidity("Units must be greater than 0")
    } else {
      this.unitsTarget.setCustomValidity("")
    }
    this.unitsTarget.reportValidity()
    this.calculateTotal()
  }

  validateUnitPrice() {
    const unitPrice = parseFloat(this.unitPriceTarget.value)
    if (unitPrice <= 0) {
      this.unitPriceTarget.setCustomValidity("Unit price must be greater than 0")
    } else {
      this.unitPriceTarget.setCustomValidity("")
    }
    this.unitPriceTarget.reportValidity()
    this.calculateTotal()
  }

  updateCurrentPrice() {
    if (this.hasUnitPriceTarget) {
      this.unitPriceTarget.value = this.element.dataset.currentPrice
      this.calculateTotal()
    }
  }
}

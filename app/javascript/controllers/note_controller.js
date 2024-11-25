import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="note"
export default class extends Controller {
  static targets = ["content", "charCount", "draftStatus", "discardButton"]
  static values = {
    maxLength: { type: Number, default: 1000 },
    draftUrl: String,
    draftInterval: { type: Number, default: 5000 },
  }

  initialize() {
    this.draftExists = false
  }

  connect() {
    this.updateCharCount()
    this.loadDraft()
    this.startAutoSave()
  }

  disconnect() {
    if (this.autoSaveInterval) {
      clearInterval(this.autoSaveInterval)
    }
  }

  updateCharCount() {
    const remaining = this.maxLengthValue - this.contentTarget.value.length
    this.charCountTarget.textContent = `${remaining} characters remaining`

    if (remaining < 50) {
      this.charCountTarget.classList.add("text-red-600", "dark:text-red-400")
      this.charCountTarget.classList.remove("text-gray-500", "dark:text-gray-400")
    } else {
      this.charCountTarget.classList.remove("text-red-600", "dark:text-red-400")
      this.charCountTarget.classList.add("text-gray-500", "dark:text-gray-400")
    }
  }

  validateContent() {
    const content = this.contentTarget.value.trim()
    if (content.length === 0) {
      this.contentTarget.setCustomValidity("Note content cannot be empty")
    } else if (content.length > this.maxLengthValue) {
      this.contentTarget.setCustomValidity(`Note content cannot exceed ${this.maxLengthValue} characters`)
    } else {
      this.contentTarget.setCustomValidity("")
    }
    this.contentTarget.reportValidity()
  }

  async loadDraft() {
    try {
      const response = await fetch(this.draftUrlValue, {
        headers: {
          Accept: "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        },
      })

      if (response.ok) {
        const draft = await response.json()
        this.contentTarget.value = draft.content
        this.element.querySelector(`input[name="note[importance]"][value="${draft.importance}"]`).checked = true
        this.updateCharCount()
        this.updateDraftStatus("Draft loaded")
        this.draftExists = true
        if (this.hasDiscardButtonTarget) {
          this.discardButtonTarget.classList.remove("hidden")
        }
      }
    } catch (error) {
      console.error("Error loading draft:", error)
    }
  }

  startAutoSave() {
    this.autoSaveInterval = setInterval(() => {
      this.saveDraft()
    }, this.draftIntervalValue)
  }

  async saveDraft() {
    const content = this.contentTarget.value.trim()
    const importance = this.element.querySelector('input[name="note[importance]"]:checked')?.value || 5

    if (!content) return

    try {
      const method = this.draftExists ? "PATCH" : "POST"
      const response = await fetch(this.draftUrlValue, {
        method: method,
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        },
        body: JSON.stringify({
          note_draft: {
            content: content,
            importance: importance,
          },
        }),
      })

      if (response.ok) {
        this.draftExists = true
        this.updateDraftStatus("Draft saved")
        if (this.hasDiscardButtonTarget) {
          this.discardButtonTarget.classList.remove("hidden")
        }
      } else {
        this.updateDraftStatus("Error saving draft")
      }
    } catch (error) {
      console.error("Error saving draft:", error)
      this.updateDraftStatus("Error saving draft")
    }
  }

  async discardDraft(event) {
    event.preventDefault()

    if (!this.draftExists) return

    try {
      const response = await fetch(this.draftUrlValue, {
        method: "DELETE",
        headers: {
          Accept: "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        },
      })

      if (response.ok) {
        this.contentTarget.value = ""
        this.element.querySelector('input[name="note[importance]"][value="5"]').checked = true
        this.updateCharCount()
        this.updateDraftStatus("Draft discarded")
        this.draftExists = false
        if (this.hasDiscardButtonTarget) {
          this.discardButtonTarget.classList.add("hidden")
        }
      } else {
        this.updateDraftStatus("Error discarding draft")
      }
    } catch (error) {
      console.error("Error discarding draft:", error)
      this.updateDraftStatus("Error discarding draft")
    }
  }

  updateDraftStatus(message) {
    if (this.hasDraftStatusTarget) {
      this.draftStatusTarget.textContent = message
      setTimeout(() => {
        this.draftStatusTarget.textContent = ""
      }, 2000)
    }
  }
}

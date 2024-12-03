import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
export default class extends Controller {
  connect() {
    const darkIcon = this.element.querySelector("#theme-toggle-dark-icon")
    const lightIcon = this.element.querySelector("#theme-toggle-light-icon")

    if (
      localStorage.getItem("color-theme") === "dark" ||
      (!("color-theme" in localStorage) && window.matchMedia("(prefers-color-scheme: dark)").matches)
    ) {
      document.documentElement.classList.add("dark")
      lightIcon.classList.remove("hidden")
    } else {
      document.documentElement.classList.remove("dark")
      darkIcon.classList.remove("hidden")
    }
  }

  toggle() {
    const darkIcon = this.element.querySelector("#theme-toggle-dark-icon")
    const lightIcon = this.element.querySelector("#theme-toggle-light-icon")

    // toggle icons
    darkIcon.classList.toggle("hidden")
    lightIcon.classList.toggle("hidden")

    // Toggle theme
    if (localStorage.getItem("color-theme")) {
      if (localStorage.getItem("color-theme") === "light") {
        document.documentElement.classList.add("dark")
        localStorage.setItem("color-theme", "dark")
      } else {
        document.documentElement.classList.remove("dark")
        localStorage.setItem("color-theme", "light")
      }
    } else {
      if (document.documentElement.classList.contains("dark")) {
        document.documentElement.classList.remove("dark")
        localStorage.setItem("color-theme", "light")
      } else {
        document.documentElement.classList.add("dark")
        localStorage.setItem("color-theme", "dark")
      }
    }
  }
}

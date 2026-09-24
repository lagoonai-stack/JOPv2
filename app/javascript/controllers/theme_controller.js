import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { current: { type: String, default: "light" } }

  connect() {
    const theme = this.storedOrSystemTheme()
    this.applyTheme(theme)
  }

  toggle() {
    const next = this.currentTheme() === "dark" ? "light" : "dark"
    localStorage.setItem("theme", next)
    this.applyTheme(next)
  }

  applyTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme)
  }

  currentTheme() {
    return document.documentElement.getAttribute("data-theme") || "light"
  }

  storedOrSystemTheme() {
    const stored = localStorage.getItem("theme")
    if (stored === "dark" || stored === "light") return stored
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }
}

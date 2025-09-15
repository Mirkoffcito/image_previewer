import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="shared--navbar"
export default class extends Controller {
  static targets = [
    "switcher",          // container of the pills
    "item",              // individual <a> pills with data-key
    "select",            // mobile <select>
    "themeToggle",       // button
    "iconLight",         // sun svg
    "iconDark"           // moon svg
  ]

  connect() {
    // --- Theme init
    this.initTheme()

    // --- Active feature detection
    const key = document.querySelector("[data-feature]")?.dataset?.feature?.trim() || this.inferKeyFromPath(location.pathname) || "preview"
    console.log("key from element", key);
    this.applyActive(key)

    // --- Keyboard shortcuts
    this.keyHandler = (e) => {
      if (e.target && /input|textarea|select/.test(e.target.tagName.toLowerCase())) return
      if (e.key === "1") this.navigate("preview")
      if (e.key === "2") this.navigate("converter")
      if (e.key === "3") this.navigate("upscale")
    }
    window.addEventListener("keydown", this.keyHandler)
  }

  disconnect() {
    window.removeEventListener("keydown", this.keyHandler)
  }

  // ============== THEME ==============
  initTheme() {
    const root = document.documentElement
    const saved = localStorage.getItem("theme")
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
    const mode = saved || (prefersDark ? "dark" : "light")
    if (mode === "dark") root.classList.add("dark")
    this.updateThemeIcons()
  }

  toggleTheme() {
    const root = document.documentElement
    const isDark = root.classList.toggle("dark")
    localStorage.setItem("theme", isDark ? "dark" : "light")
    this.updateThemeIcons()
  }

  updateThemeIcons() {
    if (!this.hasIconLightTarget || !this.hasIconDarkTarget) return
    const isDark = document.documentElement.classList.contains("dark")
    this.iconLightTarget.classList.toggle("hidden", !isDark)
    this.iconDarkTarget.classList.toggle("hidden", isDark)
  }

  // Fired by click on theme button
  themeClick() {
    this.toggleTheme()
  }

  // ============== FEATURE SWITCHER ==============
  // Keep select and pills in sync
  applyActive(key) {
    // Pills
    if (this.hasItemTarget) {
      this.itemTargets.forEach(a => {
        const active = a.dataset.key === key
        a.setAttribute("aria-selected", active ? "true" : "false")
        a.classList.toggle("bg-white", active)
        a.classList.toggle("dark:bg-gray-800", active)
        a.classList.toggle("text-gray-900", active)
        a.classList.toggle("dark:text-gray-100", active)
        a.classList.toggle("shadow", active)
        a.classList.toggle("text-gray-600", !active)
        a.classList.toggle("dark:text-gray-300", !active)
      })
    }
    // Mobile select
    if (this.hasSelectTarget) {
      const href = this.hrefForKey(key)
      if (href) this.selectTarget.value = href
    }
  }

  // Mobile select -> navigate
  selectChange(event) {
    const href = event.target.value
    if (href) window.location.href = href
  }

  // Optional: intercept pill clicks if you ever want SPA behavior.
  // Right now, just let anchor navigate normally.

  // ============== HELPERS ==============
  inferKeyFromPath(path) {
    if (path.startsWith("/converter")) return "converter"
    if (path.startsWith("/upscale")) return "upscale"
    return "preview"
  }

  hrefForKey(key) {
    switch (key) {
      case "preview": return "/preview"
      case "pdf":     return "/converter"
      case "upscale": return "/upscale"
      default:        return "/preview"
    }
  }

  navigate(key) {
    const href = this.hrefForKey(key)
    if (href) window.location.href = href
  }
}

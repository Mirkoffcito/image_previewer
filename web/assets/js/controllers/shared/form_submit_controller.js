import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "submit"]
  static values = { mode: String }

  connect() {
    console.log("Form submit controller connected!")
  }

  disableSubmit(event) {
    // prevent Turbo/Form from auto-submitting
    event.preventDefault()

    const validateSubmit = new CustomEvent("form:validate", {
      bubbles: true,
      cancelable: true,
      detail: { form: this.formTarget }
    })
    const okToProceed = this.formTarget.dispatchEvent(validateSubmit)
    if (!okToProceed) return

    // disable button and update label
    this.submitTarget.disabled = true
    console.log("mode value", this.modeValue)
    this.submitTarget.textContent = this.modeValue === "preview"
      ? "Generating…"
      : this.modeValue === "convert"
        ? "Converting…"
        : "Upscaling…"

    // re-emit an event so Dropzone (or other listeners) can handle the actual post
    this.formTarget.dispatchEvent(
      new CustomEvent("form:ready", { bubbles: true })
    )
  }
}
// assets/js/controllers/index_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "previewForm", "converterForm",
    "title", "submitPreview", "submitConvert"
  ]
  static values = { mode: String }

  connect() {
    console.log("Index controller connected!")
    this.modeValue = "preview"
    this.updateUI()
  }

  disableSubmit(event) {
    event.preventDefault()   // stops the real submission
    const submitBtn = this.modeValue === "preview"
      ? this.submitPreviewTarget
      : this.submitConvertTarget
  
    submitBtn.disabled = true
    submitBtn.textContent = this.modeValue === "preview"
      ? "Generating…"
      : "Converting…"
  
    const form = this.modeValue === "preview"
      ? this.previewFormTarget
      : this.converterFormTarget
  
    form.dispatchEvent(
      new CustomEvent("form:ready", { bubbles: true }) // dispatches new event so dropzone handles submission
    )
  }
}

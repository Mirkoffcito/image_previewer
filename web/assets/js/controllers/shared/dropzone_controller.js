import { Controller } from "@hotwired/stimulus"
import Dropzone from "dropzone"

Dropzone.autoDiscover = false

export default class extends Controller {
  static targets = ["zone", "submitFiles", "previews"]
  static values  = {
    url:      String,
    paramName:{ type: String, default: "files[]" },
    maxFiles: { type: Number, default: 10 },
    maxFilesize: { type: Number, default: 256 },
    acceptedFiles: { type: String, default: null },
    addRemoveLinks: { type: Boolean, default: true }
  }

  connect() {
    console.log("🔌 DropzoneController connected:", this.zoneTarget)
    this.dropzone = this._buildDropzone()

    this._onValidate = (e) => {
      if (!this._hasFiles()) {
        e.preventDefault() // veto
        // optional UX: toast/alert
        alert("Please add at least one file before submitting.")
      }
    }

    this._onReady = (e) => {
      e.preventDefault()
      this.dropzone.processQueue()
    }

    this.element.addEventListener("form:validate", this._onValidate)
    this.element.addEventListener("form:ready", this._onReady)
  }

  disconnect() {
    this.element.removeEventListener("form:validate", this._onValidate)
    this.element.removeEventListener("form:ready", this._onReady)
    if (this.dropzone) this.dropzone.destroy()
  }

  _hasFiles() {
    return this.dropzone && this.dropzone.getQueuedFiles().length > 0
  }

  _buildDropzone() {
    const token = document.querySelector("meta[name='csrf_token']").content
    const controller = this

    return new Dropzone(this.element, {
      url: this.urlValue,
      headers: { "X-CSRF-Token": token },
      paramName: this.paramNameValue,
      uploadMultiple: true,
      parallelUploads: this.maxFilesValue,
      maxFiles: this.maxFilesValue,
      maxFilesize: this.maxFilesizeValue,
      acceptedFiles: ".pdf,.png,.jpg,.jpeg,.gif,.tif,.tiff,.psd,.eps,.svg,.webp",
      addRemoveLinks: this.addRemoveLinksValue,
      previewsContainer: this.previewsTarget,
      createImageThumbnails: false,
      autoProcessQueue: false,
      dropZone:        this.zoneTarget,       // ← only this div accepts drops
      clickable:       this.zoneTarget,       // ← only clicks there open picker
      init: function() {
        this.on("addedfile",    (file) => controller._fileAdded(file))
        this.on("removedfile",  (file) => controller._fileRemoved(file))
        this.on("sendingmultiple", (files, xhr, formData) => {
          // e.g. append extra form fields if you need them:
          // formData.append("some_param", "value")
        })
        this.on("totaluploadprogress", (progress) => {
          controller._updateProgress(progress)
        })
        this.on("successmultiple",  (files, response) => controller._uploadSuccess(files, response))
        this.on("errormultiple",    (files, error)    => controller._uploadError(files, error))
      }
    })
  }

  // ——— Event handlers ———

  _fileAdded(file) {
    console.log("File added:", file.name)
    // e.g. enable your submit button, or show a count badge
  }

  _fileRemoved(file) {
    console.log("File removed:", file.name)
    // e.g. disable submit if no files left
  }

  _updateProgress(progress) {
    // optional: you could update a progress bar target here
    console.log(`Upload progress: ${progress}%`)
  }

  _uploadSuccess(files, response) {
    console.log("All files uploaded successfully", response)
    window.location.href = response.redirect_url
    // e.g. redirect, or render a download link
  }

  _uploadError(files, error) {
    console.error("Error uploading files:", error)
    // show an error toast, etc.
  }
}

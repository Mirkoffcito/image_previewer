// 1. bring in Stimulus
import { Application } from "@hotwired/stimulus"

// 2. start a new application
const application = Application.start()

import IndexController from "./controllers/index_controller"
application.register("index", IndexController)

import Shared__DropzoneController from "./controllers/shared/dropzone_controller"
application.register("shared--dropzone", Shared__DropzoneController)

import Shared__FormSubmitController from "./controllers/shared/form_submit_controller"
application.register("shared--form-submit", Shared__FormSubmitController)

import Shared__NavbarController from "./controllers/shared/navbar_controller"
application.register("shared--navbar", Shared__NavbarController)

import Shared__SplideController from "./controllers/shared/splide_controller"
application.register("shared--splide", Shared__SplideController)

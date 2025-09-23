require "rack"
require "rack/static"
require_relative "init"
require_relative "routes"

PUBLIC_DIR = File.expand_path("../public", __dir__)

use Rack::Static,
  urls: ["/assets", "/styles.css", "/styles.css.map", "/js", "/favicon.ico", "/tmp", "/og-image.png"],
  root: PUBLIC_DIR

# 4) mount the Cuba app
run ImagePreviewer

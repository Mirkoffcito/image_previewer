require "rack"
require "rack/static"

# 1) serve /public directly
use Rack::Static, urls: ["/public"], root: File.expand_path("..", __dir__)

# 2) bootstrap gems, load lib/
require_relative "init"

# 3) load your Cuba app definition
require_relative "routes"

# 4) mount the Cuba app
run ImagePreviewer

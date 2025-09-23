require "cuba"
require "cuba/safe"
require "cuba/render"

class ImagePreviewer < Cuba
  APP_ROOT = File.expand_path("..", __dir__)
  settings[:root] = APP_ROOT
  settings[:public] = File.join(APP_ROOT, "public")

  # middleware & plugins
  use Rack::Session::Cookie, :secret => SecureRandom.base64(64)

  plugin Safe
  plugin Render
  plugin ViewHelper # ToDo: Figure out how to import only for 'views'
  plugin ActionDispatch
  
  settings[:render] ||= {}
  settings[:render][:views] = File.expand_path("../views", __dir__)
  settings[:render][:template_engine] = "html.erb"
  settings[:render][:helpers] ||= []
  settings[:render][:helpers] << ViewHelper
end

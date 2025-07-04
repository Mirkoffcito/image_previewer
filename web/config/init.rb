require "bundler/setup"
Bundler.require(:default, ENV.fetch("RACK_ENV", :development))

# add your lib/ folder to $LOAD_PATH
Dir.chdir File.expand_path("..", __dir__)  # -> /app/web

$LOAD_PATH.unshift "../lib"
$LOAD_PATH.unshift "./concerns"
$LOAD_PATH.unshift "./lib"
$LOAD_PATH.unshift "./controllers"
$LOAD_PATH.unshift "./helpers"

# Require relevant files
Dir[File.join("../lib", "**", "*.rb")].sort.each { |file| require File.basename(file, ".rb") }

# Load concerns
Dir[File.join("concerns", "**", "*.rb")].sort.each { |file| require File.basename(file, ".rb") }
Dir[File.join("lib", "**", "*.rb")].sort.each { |file| require File.basename(file, ".rb") }

# Load controllers
Dir[File.join("controllers", "**", "*.rb")].sort.each { |file| require File.basename(file, ".rb") }

# Load helpers
Dir[File.join("helpers", "**", "*.rb")].sort.each { |file| require File.basename(file, ".rb") }


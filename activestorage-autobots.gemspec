$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "active_storage/autobots/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "activestorage-autobots"
  s.version = ActiveStorage::Autobots::VERSION
  s.authors = ["Paul Keen", "Sébastien Dubois"]
  s.email = ["pftg@jetthoughts.com"]
  s.homepage = "https://github.com/jetthoughts/activestorage-autobots"
  s.summary = "Allow to add custom ActiveStorage transformers"
  s.description = "Enables ActiveStorage variants for other file types than images," \
    "such as audio or video files, through an API for registering custom transformers similar to previewers."
  s.license = "MIT"

  s.required_ruby_version = ">= 2.5.0"

  s.files = Dir["CHANGELOG.md", "MIT-LICENSE", "README.md", "lib/**/*"]
  s.require_path = "lib"

  s.add_dependency "rails", ">= 6.1.0"
end

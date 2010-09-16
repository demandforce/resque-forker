$: << File.dirname(__FILE__) + "/lib"
require "resque/forker"

Gem::Specification.new do |spec|
  spec.name           = "resque-forker"
  spec.version        = Resque::Forker::VERSION
  spec.author         = "Assaf Arkin"
  spec.email          = "assaf@labnotes.org"
  spec.homepage       = "http://github.com/flowtown/resque-forker"
  spec.summary        = "Super awesome forking action for Resque workers"
  spec.description    = "Use the power of forking to run multiple Resque workers."
  spec.post_install_message = ""

  spec.files          = Dir["{lib,script,etc}/**/*", "CHANGELOG", "MIT-LICENSE", "README.rdoc", "Rakefile", "*.gemspec"]

  spec.has_rdoc         = true
  spec.extra_rdoc_files = "README.rdoc", "CHANGELOG"
  spec.rdoc_options     = "--title", "Resque Forker  #{spec.version}", "--main", "README.rdoc", "--webcvs", spec.homepage

  spec.required_ruby_version = '>= 1.8.7'
  spec.add_dependency "resque"
end

require_relative "lib/ruby_llm/text/version"

Gem::Specification.new do |spec|
  spec.name          = "ruby_llm-text"
  spec.version       = RubyLLM::Text::VERSION
  spec.authors       = [ "Patrick Rendal Olsen" ]
  spec.email         = [ "patrick@rendal.me" ]
  spec.homepage      = "https://github.com/patrols/ruby_llm-text"
  spec.summary       = "ActiveSupport-style LLM utilities for Ruby"
  spec.description   = "Intuitive one-liner utility methods for common LLM tasks like text summarization, translation, data extraction, classification, grammar correction, sentiment analysis, key point extraction, text rewriting, and question answering."
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}.git"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir["{lib}/**/*", "LICENSE", "README.md", "CHANGELOG.md"]
  spec.require_paths = [ "lib" ]

  # Core dependency
  spec.add_dependency "ruby_llm", "~> 1.0"

  # Development dependencies
  spec.add_development_dependency "minitest", ">= 5.20"
  spec.add_development_dependency "mocha", ">= 2.0"
  spec.add_development_dependency "rubocop-rails-omakase", "~> 1.0"
  spec.add_development_dependency "rake", "~> 13.0"
end

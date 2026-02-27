# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "groundwork-forms_rails"
  spec.version = "0.1.0"
  spec.authors = ["Ad Hoc"]
  spec.summary = "Groundwork multi-page form Rails adapter (controllers, routing helpers)"
  spec.license = "Apache-2.0"

  spec.required_ruby_version = ">= 3.2.0"

  spec.files = Dir["lib/**/*", "LICENSE", "README.md"]

  spec.add_dependency "rails", ">= 7.2"
  spec.add_dependency "groundwork-forms_core", ">= 0.1"

  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "simplecov", "~> 0.22"
end


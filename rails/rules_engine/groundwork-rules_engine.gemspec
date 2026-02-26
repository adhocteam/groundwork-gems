# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "groundwork-rules_engine"
  spec.version = "0.1.0"
  spec.authors = ["Ad Hoc"]
  spec.summary = "Groundwork rules engine: lazy-evaluated, explainable policy rules as pure Ruby"
  spec.license = "Apache-2.0"

  spec.required_ruby_version = ">= 3.2.0"

  spec.files = Dir["lib/**/*", "LICENSE", "README.md"]

  spec.add_development_dependency "rspec", "~> 3.13"
end

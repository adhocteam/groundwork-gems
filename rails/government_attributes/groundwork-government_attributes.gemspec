# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "groundwork-government_attributes"
  spec.version = "0.1.0"
  spec.authors = ["Ad Hoc"]
  spec.summary = "Structured, validated US government data types for ActiveModel/ActiveRecord models"
  spec.license = "Apache-2.0"

  spec.required_ruby_version = ">= 3.2.0"

  spec.files = Dir["lib/**/*", "LICENSE", "README.md"]

  spec.add_dependency "activemodel", ">= 7.2"

  spec.add_development_dependency "activerecord", ">= 7.2"
  spec.add_development_dependency "rspec",        "~> 3.13"
  spec.add_development_dependency "sqlite3",      "~> 2.0"
end

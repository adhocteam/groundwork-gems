# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name    = "groundwork-case_management"
  spec.version = "0.1.0"
  spec.authors = ["Ad Hoc"]
  spec.summary = "Groundwork case management Rails engine: intake forms, workflow routing, examiner task queues"
  spec.license = "Apache-2.0"

  spec.required_ruby_version = ">= 3.2.0"

  spec.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "README.md"]

  spec.add_dependency "rails",                        ">= 7.2"
  spec.add_dependency "statesman",                    ">= 12.0"
  spec.add_dependency "rails_event_store",            ">= 2.0"
  spec.add_dependency "pundit",                       ">= 2.5"
  spec.add_dependency "groundwork-forms_rails",       ">= 0.1"
  spec.add_dependency "groundwork-rules_engine",      ">= 0.1"
  spec.add_dependency "groundwork-government_attributes", ">= 0.1"

  spec.add_development_dependency "rspec-rails", "~> 7.0"
  spec.add_development_dependency "sqlite3",     "~> 2.0"
  spec.add_development_dependency "factory_bot_rails"
end

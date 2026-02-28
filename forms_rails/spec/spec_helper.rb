# frozen_string_literal: true

require "simplecov"

SimpleCov.start do
  enable_coverage :branch

  gem_root = File.expand_path("..", __dir__)
  add_filter { |source_file| !source_file.filename.start_with?(gem_root) }
  add_filter "/spec/"
end

require "groundwork-forms_rails"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end


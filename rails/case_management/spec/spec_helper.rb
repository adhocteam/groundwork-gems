# frozen_string_literal: true

require "groundwork-case_management"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

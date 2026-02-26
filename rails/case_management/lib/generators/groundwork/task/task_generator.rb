# frozen_string_literal: true

require "rails/generators"

module Groundwork
  module Generators
    # Generates a Task STI subclass and spec.
    #
    # Usage:
    #   bin/rails generate groundwork:task PermitReviewTask PermitCase
    #
    class TaskGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      argument :case_class_name, type: :string, banner: "CaseClassName"

      desc "Generates a Groundwork::StaffTask subclass and spec"

      def create_task_file
        template "task.rb.tt", "app/tasks/#{file_name}.rb"
      end

      def create_spec
        template "task_spec.rb.tt", "spec/tasks/#{file_name}_spec.rb"
      end
    end
  end
end

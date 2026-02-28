# frozen_string_literal: true

require "rails/generators"

module Groundwork
  module Generators
    # Generates a WorkflowDefinition and its WorkflowRouter.
    #
    # Usage:
    #   bin/rails generate groundwork:workflow PermitWorkflow PermitCase
    #
    class WorkflowGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      argument :case_class_name, type: :string, banner: "CaseClassName"

      desc "Generates a WorkflowDefinition and WorkflowRouter for a Case class"

      def create_workflow_file
        template "workflow.rb.tt", "app/workflows/#{file_name}.rb"
      end

      def create_router_file
        template "workflow_router.rb.tt", "app/workflows/#{router_file_name}.rb"
      end

      def create_spec
        template "workflow_spec.rb.tt", "spec/workflows/#{file_name}_spec.rb"
      end

      private

      def router_file_name
        "#{file_name.sub("_workflow", "")}_workflow_router"
      end

      def router_class_name
        "#{class_name.sub("Workflow", "")}WorkflowRouter"
      end
    end
  end
end

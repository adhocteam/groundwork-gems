# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module Groundwork
  module Generators
    # Generates a Case subclass, its Statesman state machine, migration, and spec.
    #
    # Usage:
    #   bin/rails generate groundwork:case PermitCase
    #
    class CaseGenerator < Rails::Generators::NamedBase
      include ActiveRecord::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      desc "Generates a Groundwork::Case subclass with Statesman machine, migration, and spec"

      def create_case_file
        template "case.rb.tt", "app/cases/#{file_name}.rb"
      end

      def create_state_machine_file
        template "case_state_machine.rb.tt", "app/state_machines/#{file_name}_state_machine.rb"
      end

      def create_migration
        migration_template "migration.rb.tt", "db/migrate/create_#{table_name}.rb"
      end

      def create_spec
        template "case_spec.rb.tt", "spec/cases/#{file_name}_spec.rb"
      end

      private

      def table_name
        file_name.pluralize
      end

      def workflow_name
        class_name.sub("Case", "Workflow")
      end
    end
  end
end

# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module Groundwork
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      desc "Installs Groundwork: copies initializer and creates base migration"

      def create_initializer
        template "initializer.rb", "config/initializers/groundwork.rb"
      end

      def copy_migration
        migration_template "migration.rb", "db/migrate/create_groundwork_tables.rb"
      end
    end
  end
end

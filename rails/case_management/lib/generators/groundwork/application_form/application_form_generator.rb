# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module Groundwork
  module Generators
    # Generates an ApplicationForm subclass and its migration.
    #
    # Usage:
    #   bin/rails generate groundwork:application_form PermitApplicationForm \
    #     applicant_name:name business_address:address business_ein:ein
    #
    class ApplicationFormGenerator < Rails::Generators::NamedBase
      include ActiveRecord::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      argument :attributes, type: :array, default: [], banner: "field:type field:type"

      desc "Generates a Groundwork::ApplicationForm subclass, migration, and spec"

      def create_form_file
        template "application_form.rb.tt", "app/application_forms/#{file_name}.rb"
      end

      def create_migration
        migration_template "migration.rb.tt", "db/migrate/create_#{table_name}.rb"
      end

      def create_spec
        template "application_form_spec.rb.tt", "spec/application_forms/#{file_name}_spec.rb"
      end

      private

      def gov_attributes
        attributes.select { |a| GOV_TYPES.include?(a.type.to_sym) }
      end

      def plain_attributes
        attributes.reject { |a| GOV_TYPES.include?(a.type.to_sym) }
      end

      def migration_columns
        base = Groundwork::ApplicationForm.base_columns_for_migration
        base + attributes.flat_map { |a| columns_for(a) }
      end

      GOV_TYPES = %i[name address ein tax_id money memorable_date].freeze

      def columns_for(attr)
        case attr.type.to_sym
        when :address       then %W[#{attr.name}_street_line_1:string #{attr.name}_street_line_2:string #{attr.name}_city:string #{attr.name}_state:string #{attr.name}_zip_code:string]
        when :name          then %W[#{attr.name}_first:string #{attr.name}_middle:string #{attr.name}_last:string #{attr.name}_suffix:string]
        when :memorable_date then %W[#{attr.name}_year:integer #{attr.name}_month:integer #{attr.name}_day:integer]
        when :ein, :tax_id  then %W[#{attr.name}:string]
        when :money         then %W[#{attr.name}:integer]
        else                     %W[#{attr.name}:#{attr.type}]
        end
      end

      def table_name
        file_name.pluralize
      end
    end
  end
end

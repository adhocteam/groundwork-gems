# frozen_string_literal: true

require "rails/generators"
require "json"

lib_root = File.expand_path("../../../../lib/groundwork/forms/generators", __dir__)
require "#{lib_root}/field_deriver"
require "#{lib_root}/type_mapper"
require "#{lib_root}/checkbox_pairer"
require "#{lib_root}/manifest_parser"

module Groundwork
  module Generators
    class FormGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      class_option :fields,
        type: :string, required: true,
        desc: "Path to form-fields.json"
      class_option :journey,
        type: :string, required: true,
        desc: "Path to runtime-guards.json"
      class_option :namespace,
        type: :string, default: "applicant",
        desc: "View/controller namespace (default: applicant)"

      def parse_inputs
        @manifest = Groundwork::Forms::Generators::ManifestParser.call(
          fields_path:  options[:fields],
          journey_path: options[:journey]
        )
      rescue Groundwork::Forms::Generators::ManifestParser::Error => e
        raise Thor::Error, "ERROR: #{e.message}"
      end

      def pair_and_derive
        pairer  = Groundwork::Forms::Generators::CheckboxPairer.new
        deriver = Groundwork::Forms::Generators::FieldDeriver.new
        mapper  = Groundwork::Forms::Generators::TypeMapper.new

        @fields_by_page = @manifest.fields_by_page.transform_values do |fields|
          pairer.call(fields)
        end

        all_fields    = @fields_by_page.values.flatten
        source_texts  = all_fields.map { |f| f.dig("pdf", "tu").to_s.then { |t| t.empty? ? f.dig("label", "text").to_s : t } }
        derived_names = deriver.call_all(source_texts)

        @attributes = all_fields.zip(derived_names).map do |field, name|
          { id: field["id"], field: field, name: name, type: mapper.call(field), page: field["page"] }
        end

        @skip_count   = @attributes.count { |a| a[:type] == :skip }
        @paired_count = all_fields.count { |f| f["_paired"] }
        @warn_count   = @attributes.count { |a| a[:name].start_with?("field_") }
      end

      def assign_steps_interactively
        say "\nFound #{@manifest.steps.length} steps in journey: #{@manifest.steps.join(', ')}"
        say "Found #{@manifest.pages.length} pages in form:"
        @manifest.pages.each do |page|
          fields = @fields_by_page[page] || []
          preview = @attributes.select { |a| a[:page] == page }.first(3).map { |a| a[:name] }
          say "  Page #{page} — #{fields.length} fields (#{preview.join(', ')}...)"
        end
        say ""

        @step_assignments = {}
        @manifest.steps.each do |step|
          input = ask("Assign pages to step '#{step}' (e.g. 1 or 1-2, blank for review/no fields):")
          @step_assignments[step] = parse_page_range(input.to_s.strip)
        end

        validate_assignments!
      end

      def generate_model
        active = @attributes.reject { |a| a[:type] == :skip }
        args   = ["#{class_name}Form"] + active.map { |a| "#{a[:name]}:#{a[:type]}" }
        Rails::Generators.invoke(
          "groundwork:application_form",
          args,
          behavior: behavior,
          destination_root: destination_root
        )
      end

      def create_flow
        template "flow.rb.tt", "app/flows/#{file_name}_flow.rb"
      end

      def create_step_views
        ns = options[:namespace]
        @step_assignments.each do |step, pages|
          next if pages.nil? || pages.empty?

          @current_step = step.tr("-", "_").to_sym
          raw_fields    = fields_for_pages(pages)
          @current_step_attributes = raw_fields.filter_map do |f|
            a = attr_by_id[f["id"]]
            next if a.nil? || a[:type] == :skip
            a.merge(label: tooltip_or_label_for(f))
          end

          template "edit_step.html.erb.tt",
                   "app/views/#{ns}/#{plural_name}/edit_#{@current_step}.html.erb"
          template "step_partial.html.erb.tt",
                   "app/views/#{ns}/#{plural_name}/_step_#{@current_step}.html.erb"
        end
      end

      def create_review_view
        ns = options[:namespace]
        review_step = @step_assignments.find { |_, pages| pages.nil? || pages.empty? }&.first
        return unless review_step

        @review_step = review_step.tr("-", "_").to_sym
        template "review_step.html.erb.tt",
                 "app/views/#{ns}/#{plural_name}/edit_#{@review_step}.html.erb"
      end

      def print_field_report
        say "\nFIELD MAPPING REPORT — #{class_name}Form"
        say "─" * 60
        say format("%-45s → %-25s %-8s %s", "PDF field", "Ruby attribute", "type", "step")

        step_for_field = {}
        @step_assignments.each do |step, pages|
          (pages || []).each do |page|
            (@fields_by_page[page] || []).each do |f|
              step_for_field[f["id"]] = step
            end
          end
        end

        @attributes.each do |attr|
          type_str = attr[:type] == :skip ? "SKIPPED" : attr[:type].to_s
          step_str = step_for_field[attr[:id]] || "—"
          say format("%-45s → %-25s %-8s %s", attr[:id].to_s.last(45), attr[:name], type_str, step_str)
        end

        say ""
        say "WARN: #{@skip_count} signature field(s) skipped" if @skip_count > 0
        say "WARN: #{@paired_count * 2} yes/no checkboxes collapsed to #{@paired_count} boolean field(s)" if @paired_count > 0
      end

      private

      def parse_page_range(input)
        return [] if input.empty?
        parts = input.split("-").map(&:to_i)
        if parts.length == 2 && parts.first > parts.last
          raise Thor::Error, "ERROR: Invalid page range '#{input}' — start must be ≤ end"
        end
        (parts.first..parts.last).to_a
      end

      def validate_assignments!
        @step_assignments.each do |step, pages|
          (pages || []).each do |page|
            unless @manifest.pages.include?(page)
              raise Thor::Error,
                "ERROR: Page #{page} assigned to step '#{step}' but form only has #{@manifest.pages.length} pages"
            end
          end
        end
      end

      def attr_by_id
        @attr_by_id ||= @attributes.index_by { |a| a[:id] }
      end

      def fields_for_pages(pages)
        (pages || []).flat_map { |p| @fields_by_page[p] || [] }
      end

      def step_field_names(pages)
        fields_for_pages(pages)
          .filter_map { |f| attr_by_id[f["id"]]&.then { |a| a[:type] == :skip ? nil : a[:name] } }
      end

      def plural_name
        file_name.pluralize
      end

      def tooltip_or_label_for(field)
        tu = field.dig("pdf", "tu").to_s
        raw = tu.empty? ? field.dig("label", "text").to_s : tu
        raw.sub(/\A\d+\.\s*/, "").gsub(/\s*\([^)]*\)/, "").strip
      end
    end
  end
end

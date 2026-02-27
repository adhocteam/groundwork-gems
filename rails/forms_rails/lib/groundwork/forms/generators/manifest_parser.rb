# frozen_string_literal: true

require "json"

module Groundwork
  module Forms
    module Generators
      class ManifestParser
        Error = Class.new(StandardError)

        Result = Data.define(:steps, :pages, :fields_by_page)

        def self.call(fields_path:, journey_path:)
          new(fields_path: fields_path, journey_path: journey_path).call
        end

        def initialize(fields_path:, journey_path:)
          @fields_path  = fields_path
          @journey_path = journey_path
        end

        def call
          fields_json  = read_json!(@fields_path)
          journey_json = read_json!(@journey_path)

          fields = fields_json.fetch("fields")
          steps  = journey_json.fetch("steps").keys

          fields_by_page = fields.group_by { |f| f["page"] }.sort.to_h

          Result.new(
            steps:          steps,
            pages:          fields_by_page.keys,
            fields_by_page: fields_by_page
          )
        end

        private

        def read_json!(path)
          raise Error, "not found: #{path}" unless File.exist?(path)

          JSON.parse(File.read(path))
        end
      end
    end
  end
end

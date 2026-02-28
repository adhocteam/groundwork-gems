# frozen_string_literal: true

module Groundwork
  module Forms
    module Generators
      class TypeMapper
        def call(field)
          case field["kind"]
          when "text"
            field.dig("pdf", "flags", "multiline") ? :text : :string
          when "checkbox"
            :boolean
          when "signature"
            :skip
          else
            :string
          end
        end
      end
    end
  end
end

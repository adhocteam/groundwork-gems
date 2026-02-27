# frozen_string_literal: true

module Groundwork
  module Forms
    module Generators
      class CheckboxPairer
        def call(fields)
          result = []
          i = 0
          while i < fields.length
            current = fields[i]
            nxt     = fields[i + 1]
            if yes_no_pair?(current, nxt)
              result << current.merge("_paired" => true)
              i += 2
            else
              result << current
              i += 1
            end
          end
          result
        end

        private

        def yes_no_pair?(a, b)
          return false if b.nil?
          return false unless a["kind"] == "checkbox" && b["kind"] == "checkbox"
          return false unless a["page"] == b["page"]

          labels = [tooltip_or_label(a).downcase, tooltip_or_label(b).downcase]
          labels.any? { |l| l.include?("yes") } && labels.any? { |l| l.include?("no") }
        end

        def tooltip_or_label(field)
          field.dig("pdf", "tu").to_s.then { |t| t.empty? ? field.dig("label", "text").to_s : t }
        end
      end
    end
  end
end

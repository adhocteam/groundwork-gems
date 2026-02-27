# frozen_string_literal: true

module Groundwork
  module Forms
    module Generators
      class FieldDeriver
        FILLER_WORDS = %w[of the a an and or in for to].freeze

        def call(source)
          text = source.to_s
          text = strip_ordinal(text)
          text = strip_parentheticals(text)
          words = significant_words(text)
          words.first(3).join("_").downcase
        end

        def call_all(sources)
          names = sources.map { |s| call(s) }
          deduplicate(names)
        end

        private

        def strip_ordinal(text)
          text.sub(/\A\d+\.\s*/, "")
        end

        def strip_parentheticals(text)
          text.gsub(/\s*\([^)]*\)/, "").strip
        end

        def significant_words(text)
          text.split(/\s+/)
              .map { |w| w.gsub(/[^a-z0-9]/i, "") }
              .reject { |w| w.empty? || FILLER_WORDS.include?(w.downcase) }
        end

        def deduplicate(names)
          seen = Hash.new(0)
          names.map do |name|
            seen[name] += 1
            n = seen[name]
            n == 1 ? name : "#{name}_#{n}"
          end
        end
      end
    end
  end
end

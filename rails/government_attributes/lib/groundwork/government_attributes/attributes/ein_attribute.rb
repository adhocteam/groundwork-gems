# frozen_string_literal: true

module Groundwork
  module GovernmentAttributes
    module Attributes
      module EinAttribute
        extend ActiveSupport::Concern

        class EinType < ActiveModel::Type::String
          def cast(value)
            return nil if value.nil?
            return value if value.is_a?(Ein)

            Ein.new(value)
          end

          def type
            :ein
          end
        end

        class_methods do
          def ein_attribute(name, _options = {})
            attribute name, EinType.new
            validates name,
                      format: { with: Ein::FORMAT_WITHOUT_DASH, message: "must be 9 digits" },
                      allow_nil: true
          end
        end
      end
    end
  end
end

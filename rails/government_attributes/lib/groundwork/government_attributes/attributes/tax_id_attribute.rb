# frozen_string_literal: true

module Groundwork
  module GovernmentAttributes
    module Attributes
      module TaxIdAttribute
        extend ActiveSupport::Concern

        class TaxIdType < ActiveModel::Type::String
          def cast(value)
            return nil if value.nil?
            return value if value.is_a?(TaxId)

            TaxId.new(value)
          end

          def type
            :tax_id
          end
        end

        class_methods do
          def tax_id_attribute(name, _options = {})
            attribute name, TaxIdType.new
            validates name,
                      format: { with: TaxId::FORMAT_WITHOUT_DASHES, message: "must be 9 digits" },
                      allow_nil: true
          end
        end
      end
    end
  end
end

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

          def serialize(value)
            return nil if value.nil?

            cast(value).digits
          end

          def type
            :tax_id
          end
        end

        class_methods do
          def tax_id_attribute(name, _options = {})
            attribute name, TaxIdType.new

            define_method(:"#{name}_digits") do
              public_send(name)&.digits
            end

            define_method(:"#{name}_digits=") do |digits|
              public_send(:"#{name}=", digits)
            end

            validate_method_name = :"validate_#{name}_digits_format"
            define_method(validate_method_name) do
              value = public_send(name)
              return if value.nil?

              digits = value.digits
              return if digits.match?(TaxId::FORMAT_WITHOUT_DASHES)

              errors.add(name, "must be 9 digits")
            end
            validate validate_method_name
          end
        end
      end
    end
  end
end

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

          def serialize(value)
            return nil if value.nil?

            cast(value).digits
          end

          def type
            :ein
          end
        end

        class_methods do
          def ein_attribute(name, _options = {})
            attribute name, EinType.new

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
              return if digits.match?(Ein::FORMAT_WITHOUT_DASH)

              errors.add(name, "must be 9 digits")
            end
            validate validate_method_name
          end
        end
      end
    end
  end
end

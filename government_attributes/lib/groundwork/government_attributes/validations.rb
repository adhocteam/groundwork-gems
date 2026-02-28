# frozen_string_literal: true

module Groundwork
  module GovernmentAttributes
    # Provides gov_validates_nested — wires validation delegation from an AR
    # model down into a composed ValueObject attribute.
    module Validations
      extend ActiveSupport::Concern

      class_methods do
        # Adds a validation that delegates to the value object's own validate.
        # Errors are promoted up with the attribute name as prefix.
        #
        # @param attribute_name [Symbol]
        def gov_validates_nested(attribute_name)
          validate do
            value = public_send(attribute_name)
            next if value.nil? || value.blank?
            next if value.valid?

            value.errors.each do |error|
              errors.add("#{attribute_name}_#{error.attribute}", error.message)
            end
          end
        end
      end
    end
  end
end

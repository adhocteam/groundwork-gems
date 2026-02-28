# frozen_string_literal: true

module Groundwork
  module GovernmentAttributes
    module Attributes
      # Internal concern used by all multi-column value object attribute modules.
      # Not intended to be used directly by application code.
      #
      # For each composite attribute it:
      # - Defines individual AR columns for each sub-field
      # - Generates a getter that assembles the value object from sub-fields
      # - Generates a setter that accepts either a value object or a plain hash
      # - Wires gov_validates_nested delegation
      module BasicValueObjectAttribute
        extend ActiveSupport::Concern
        include Groundwork::GovernmentAttributes::Validations

        class_methods do
          # @param name                  [Symbol]        attribute name (e.g. :premises_address)
          # @param value_class           [Class]         ValueObject subclass
          # @param nested_attribute_types [Hash{String=>Symbol}]  sub-field name → AR type
          def basic_value_object_attribute(name, value_class, nested_attribute_types, _options = {})
            nested_attribute_types.each do |sub_name, sub_type|
              attribute :"#{name}_#{sub_name}", sub_type
            end

            define_method(name) do
              value_hash = nested_attribute_types.keys.to_h do |sub_name|
                [sub_name, public_send(:"#{name}_#{sub_name}")]
              end
              return nil if value_hash.values.all?(&:nil?)

              value_class.new(value_hash)
            end

            define_method(:"#{name}=") do |value|
              case value
              when value_class
                nested_attribute_types.keys.each do |sub_name|
                  public_send(:"#{name}_#{sub_name}=", value.public_send(sub_name))
                end
              when Hash
                nested_attribute_types.keys.each do |sub_name|
                  val = value[sub_name.to_sym] || value[sub_name.to_s]
                  public_send(:"#{name}_#{sub_name}=", val)
                end
              end
            end

            gov_validates_nested(name)
          end
        end
      end
    end
  end
end

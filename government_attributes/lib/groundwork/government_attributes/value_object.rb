# frozen_string_literal: true

module Groundwork
  module GovernmentAttributes
    # Base class for immutable value objects used in government data models.
    #
    # Subclasses use ActiveModel attribute/validation DSL and gain:
    # - Value equality (by attribute content, not object identity)
    # - blank?/present? based on attribute values
    # - JSON serialization
    #
    # @example
    #   class MyValue < Groundwork::GovernmentAttributes::ValueObject
    #     attribute :code, :string
    #     validates :code, presence: true
    #   end
    class ValueObject
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::AttributeAssignment
      include ActiveModel::Validations
      include ActiveModel::Serializers::JSON

      def ==(other)
        return false unless other.is_a?(self.class)

        attributes.all? do |name, _|
          public_send(name) == other.public_send(name)
        end
      end

      def blank?
        attributes.values.all?(&:blank?)
      end

      def present?
        !blank?
      end

      # Required by ActiveModel::Serializers::JSON
      def persisted?
        false
      end
    end
  end
end

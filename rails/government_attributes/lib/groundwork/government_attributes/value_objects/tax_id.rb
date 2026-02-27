# frozen_string_literal: true

module Groundwork
  module GovernmentAttributes
    # US Social Security Number (SSN). Stored as a 9-digit string without dashes.
    class TaxId < ValueObject
      FORMAT_WITH_DASHES    = /\A\d{3}-\d{2}-\d{4}\z/
      FORMAT_WITHOUT_DASHES = /\A\d{9}\z/

      attribute :digits, :string

      validates :digits, format: { with: FORMAT_WITHOUT_DASHES, message: "must be 9 digits" }, allow_nil: true

      def initialize(value = nil)
        normalized = value.is_a?(String) ? value.gsub("-", "") : value
        super(digits: normalized)
      end

      # Returns XXX-XX-1234 masked format for display
      def masked
        return nil if digits.nil?
        "XXX-XX-#{digits[-4, 4]}"
      end

      def to_s
        return "" if digits.nil?
        "#{digits[0..2]}-#{digits[3..4]}-#{digits[5..8]}"
      end
    end
  end
end

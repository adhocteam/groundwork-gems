# frozen_string_literal: true

module Groundwork
  module GovernmentAttributes
    # US Employer Identification Number (EIN). Format: XX-XXXXXXX (9 digits).
    # Used for business entities on licensing applications.
    class Ein < ValueObject
      FORMAT_WITH_DASH    = /\A\d{2}-\d{7}\z/
      FORMAT_WITHOUT_DASH = /\A\d{9}\z/

      attribute :digits, :string

      validates :digits, format: { with: FORMAT_WITHOUT_DASH, message: "must be 9 digits" }, allow_nil: true

      def initialize(value = nil)
        normalized = value.is_a?(String) ? value.gsub("-", "") : value
        super(digits: normalized)
      end

      def to_s
        return "" if digits.nil?
        "#{digits[0..1]}-#{digits[2..8]}"
      end
    end
  end
end

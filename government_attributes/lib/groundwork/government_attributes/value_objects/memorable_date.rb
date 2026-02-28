# frozen_string_literal: true

module Groundwork
  module GovernmentAttributes
    # A date entered as separate year/month/day fields (common in government forms).
    # Accepts partial input gracefully — useful for in-progress draft forms.
    class MemorableDate < ValueObject
      attribute :year,  :integer
      attribute :month, :integer
      attribute :day,   :integer

      validates :year,  numericality: { only_integer: true, greater_than: 1900 }, allow_nil: true
      validates :month, numericality: { only_integer: true, in: 1..12 }, allow_nil: true
      validates :day,   numericality: { only_integer: true, in: 1..31 }, allow_nil: true
      validate  :date_must_be_valid, if: :all_parts_present?

      # Convert to a Ruby Date if all parts are present and valid.
      #
      # @return [Date, nil]
      def to_date
        return nil unless all_parts_present? && valid?
        Date.new(year, month, day)
      rescue Date::Error
        nil
      end

      def to_s
        return "" unless all_parts_present?
        format("%04d-%02d-%02d", year, month, day)
      end

      private

      def all_parts_present?
        year.present? && month.present? && day.present?
      end

      def date_must_be_valid
        Date.new(year, month, day)
      rescue Date::Error
        errors.add(:base, "is not a valid date")
      end
    end
  end
end

# frozen_string_literal: true

module Groundwork
  module GovernmentAttributes
    class Name < ValueObject
      attribute :first,  :string
      attribute :middle, :string
      attribute :last,   :string
      attribute :suffix, :string

      validates :first, presence: true
      validates :last,  presence: true

      def full_name
        [first, middle, last, suffix].reject(&:blank?).join(" ")
      end

      def to_s
        full_name
      end
    end
  end
end

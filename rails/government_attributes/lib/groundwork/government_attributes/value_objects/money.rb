# frozen_string_literal: true

module Groundwork
  module GovernmentAttributes
    # US dollar amount stored as integer cents.
    # Supports arithmetic, comparison, and formatted display.
    class Money < ValueObject
      include Comparable
      include ActiveSupport::NumberHelper

      attribute :cents, :integer

      validates :cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

      def initialize(cents_or_attrs = nil)
        case cents_or_attrs
        when Integer      then super(cents: cents_or_attrs)
        when Hash         then super(cents_or_attrs)
        when nil          then super(cents: nil)
        else
          raise ArgumentError, "Money expects an Integer (cents) or Hash, got #{cents_or_attrs.class}"
        end
      end

      def +(other)
        raise TypeError, "cannot add #{other.class} to Money" unless other.is_a?(Money)
        self.class.new(cents + other.cents)
      end

      def -(other)
        raise TypeError, "cannot subtract #{other.class} from Money" unless other.is_a?(Money)
        self.class.new(cents - other.cents)
      end

      def *(scalar)
        self.class.new((cents * scalar.to_f).round)
      end

      def /(scalar)
        self.class.new((cents / scalar.to_f).floor)
      end

      def dollar_amount
        BigDecimal(cents.to_s) / 100
      end

      def <=>(other)
        return nil unless other.is_a?(Money)
        cents <=> other.cents
      end

      def eql?(other)
        (self <=> other) == 0
      end

      def hash
        cents.hash
      end

      def to_s
        number_to_currency(dollar_amount)
      end
    end
  end
end

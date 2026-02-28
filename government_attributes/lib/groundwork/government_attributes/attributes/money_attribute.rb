# frozen_string_literal: true

module Groundwork
  module GovernmentAttributes
    module Attributes
      module MoneyAttribute
        extend ActiveSupport::Concern

        # Custom AR type that casts through Money.
        class MoneyType < ActiveModel::Type::Integer
          def cast(value)
            return nil if value.nil?
            return value if value.is_a?(Money)

            Money.new(super(value))
          end

          def serialize(value)
            return nil if value.nil?
            value.is_a?(Money) ? value.cents : value.to_i
          end

          def type
            :money
          end
        end

        class_methods do
          def money_attribute(name, _options = {})
            attribute name, MoneyType.new
          end
        end
      end
    end
  end
end

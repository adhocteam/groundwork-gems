# frozen_string_literal: true

module Groundwork
  module GovernmentAttributes
    module Attributes
      module MemorableDateAttribute
        extend ActiveSupport::Concern
        include BasicValueObjectAttribute

        class_methods do
          def memorable_date_attribute(name, options = {})
            basic_value_object_attribute(name, MemorableDate, {
              "year"  => :integer,
              "month" => :integer,
              "day"   => :integer
            }, options)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Groundwork
  module GovernmentAttributes
    module Attributes
      module AddressAttribute
        extend ActiveSupport::Concern
        include BasicValueObjectAttribute

        class_methods do
          def address_attribute(name, options = {})
            basic_value_object_attribute(name, Address, {
              "street_line_1" => :string,
              "street_line_2" => :string,
              "city"          => :string,
              "state"         => :string,
              "zip_code"      => :string
            }, options)
          end
        end
      end
    end
  end
end

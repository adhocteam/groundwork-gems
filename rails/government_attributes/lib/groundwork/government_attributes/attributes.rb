# frozen_string_literal: true

module Groundwork
  module GovernmentAttributes
    # Concern that adds the `gov_attribute` DSL to any ActiveModel/ActiveRecord model.
    #
    # @example
    #   class MyForm < ApplicationRecord
    #     include Groundwork::GovernmentAttributes::Attributes
    #
    #     gov_attribute :applicant_name,   :name
    #     gov_attribute :premises_address, :address
    #     gov_attribute :business_ein,     :ein
    #     gov_attribute :license_fee,      :money
    #     gov_attribute :date_of_birth,    :memorable_date
    #   end
    module Attributes
      extend ActiveSupport::Concern

      include Attributes::AddressAttribute
      include Attributes::NameAttribute
      include Attributes::MoneyAttribute
      include Attributes::TaxIdAttribute
      include Attributes::EinAttribute
      include Attributes::MemorableDateAttribute

      class_methods do
        # Defines a government-typed attribute.
        #
        # @param name    [Symbol]  attribute name
        # @param type    [Symbol]  one of: :address, :name, :money, :tax_id, :ein, :memorable_date
        # @param options [Hash]    passed through to the underlying attribute method
        def gov_attribute(name, type, options = {})
          method_name = :"#{type}_attribute"

          if respond_to?(method_name, true)
            send(method_name, name, options)
          else
            # Fall back to ActiveModel::Attributes for unrecognized types
            attribute name, type, **options
          end
        end
      end
    end
  end
end

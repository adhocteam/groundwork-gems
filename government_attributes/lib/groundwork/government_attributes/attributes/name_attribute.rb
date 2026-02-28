# frozen_string_literal: true

module Groundwork
  module GovernmentAttributes
    module Attributes
      module NameAttribute
        extend ActiveSupport::Concern
        include BasicValueObjectAttribute

        class_methods do
          def name_attribute(name, options = {})
            basic_value_object_attribute(name, Name, {
              "first"  => :string,
              "middle" => :string,
              "last"   => :string,
              "suffix" => :string
            }, options)
          end
        end
      end
    end
  end
end

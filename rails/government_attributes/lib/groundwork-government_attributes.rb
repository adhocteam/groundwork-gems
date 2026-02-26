# frozen_string_literal: true

require "active_model"
require "active_support/concern"
require "active_support/core_ext/string/inflections"
require "bigdecimal"
require "active_support/number_helper"

require "groundwork/government_attributes/value_object"
require "groundwork/government_attributes/validations"

require "groundwork/government_attributes/value_objects/address"
require "groundwork/government_attributes/value_objects/name"
require "groundwork/government_attributes/value_objects/money"
require "groundwork/government_attributes/value_objects/tax_id"
require "groundwork/government_attributes/value_objects/ein"
require "groundwork/government_attributes/value_objects/memorable_date"

require "groundwork/government_attributes/attributes/basic_value_object_attribute"
require "groundwork/government_attributes/attributes/address_attribute"
require "groundwork/government_attributes/attributes/name_attribute"
require "groundwork/government_attributes/attributes/money_attribute"
require "groundwork/government_attributes/attributes/tax_id_attribute"
require "groundwork/government_attributes/attributes/ein_attribute"
require "groundwork/government_attributes/attributes/memorable_date_attribute"

require "groundwork/government_attributes/attributes"

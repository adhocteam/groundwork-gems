# groundwork-government_attributes

`groundwork-government_attributes` adds government-domain value objects to ActiveModel and ActiveRecord models through a single DSL: `gov_attribute`.

It is designed for intake and case-management domains where fields like names, addresses, dates, EINs, and SSNs need consistent parsing, validation, and formatting.

## Requirements

- Ruby `>= 3.2.0`
- `activemodel >= 7.2`

## Installation

Add to your Gemfile:

```ruby
gem "groundwork-government_attributes"
```

Then install:

```sh
bundle install
```

## Quick Start (ActiveRecord)

```ruby
class PermitApplication < ApplicationRecord
  include Groundwork::GovernmentAttributes::Attributes

  gov_attribute :applicant_name, :name
  gov_attribute :business_address, :address
  gov_attribute :business_ein, :ein
  gov_attribute :application_fee, :money
  gov_attribute :date_of_birth, :memorable_date
end
```

```ruby
application = PermitApplication.new

application.applicant_name = { first: "Jane", last: "Smith" }
application.business_ein = "12-3456789"
application.application_fee = 1250
application.date_of_birth = { year: 1990, month: 4, day: 23 }

application.applicant_name.full_name # => "Jane Smith"
application.business_ein.to_s        # => "12-3456789"
application.application_fee.to_s     # => "$12.50"
application.date_of_birth.to_s       # => "1990-04-23"
```

## Supported Types and Storage

`gov_attribute` maps each type to either multiple backing fields or a custom ActiveModel type.

| Type | Backing fields | Stored value |
| --- | --- | --- |
| `:name` | `<attr>_first`, `<attr>_middle`, `<attr>_last`, `<attr>_suffix` | strings |
| `:address` | `<attr>_street_line_1`, `<attr>_street_line_2`, `<attr>_city`, `<attr>_state`, `<attr>_zip_code` | strings |
| `:memorable_date` | `<attr>_year`, `<attr>_month`, `<attr>_day` | integers |
| `:money` | `<attr>` | integer cents, cast to `Money` |
| `:tax_id` | `<attr>` | 9-digit string, cast to `TaxId` |
| `:ein` | `<attr>` | 9-digit string, cast to `Ein` |

For `:tax_id` and `:ein`, convenience accessors are also defined:

- `<attr>_digits`
- `<attr>_digits=`

## Validation Behavior

### Nested value objects (`:name`, `:address`, `:memorable_date`)

Nested object errors are promoted to model errors using `<attr>_<field>`.

Example:

- invalid `applicant_name.first` becomes an error on `applicant_name_first`
- an invalid full date in `memorable_date` may surface as `<attr>_base`

### `:tax_id` and `:ein`

Both cast to objects that normalize input by removing dashes and validate that exactly 9 digits are present.

### Partial-input semantics

- Value objects treat blank content as in-progress input.
- `MemorableDate` allows partial year/month/day input and only validates calendar correctness when all three parts are present.

## ActiveModel Usage (No Full Rails App Required)

You can use the DSL in plain ActiveModel classes:

```ruby
class IntakeForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include Groundwork::GovernmentAttributes::Attributes

  gov_attribute :applicant_name, :name
  gov_attribute :business_ein, :ein
end
```

## Development

Run specs for this gem:

```sh
cd government_attributes
bundle install
bundle exec rspec
```

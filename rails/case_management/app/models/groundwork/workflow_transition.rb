# frozen_string_literal: true

module Groundwork
  # Statesman transitions table. Records every workflow state change with a
  # full audit trail including who triggered the transition and any metadata.
  #
  # This is a concrete table shared across all case types via polymorphic
  # case_id / case_type columns.
  class WorkflowTransition < ApplicationRecord
    include Statesman::Adapters::ActiveRecord

    belongs_to :case, polymorphic: true

    # metadata column (jsonb) stores: triggered_by_id, event_name, notes, etc.
    validates :to_state, presence: true
  end
end

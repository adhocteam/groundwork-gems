# frozen_string_literal: true

module Groundwork
  # Base class for case workflow instances.
  #
  # A Case is created when an ApplicationForm is submitted and tracks the
  # workflow's progression through steps. State transitions are persisted via
  # Statesman, giving a full audit trail of every step change.
  #
  # Subclasses declare their workflow and add program-specific columns.
  #
  # @example
  #   class PermitCase < Groundwork::Case
  #     # workflow is inferred from PermitWorkflow constant by convention,
  #     # or override:
  #     def self.workflow_definition
  #       PermitWorkflow
  #     end
  #   end
  #
  class Case < ApplicationRecord
    self.abstract_class = true

    has_many :workflow_transitions, as: :case, class_name: "Groundwork::WorkflowTransition"
    has_many :tasks, as: :case, class_name: "Groundwork::Task"

    attribute :application_form_id, :string
    attribute :current_step,        :string
    attribute :facts,               :jsonb,   default: {}

    enum :status, { open: 0, closed: 1 }, prefix: false
    protected attr_writer :status

    # Cases currently waiting on staff action.
    scope :actionable, -> {
      open.where(current_step: workflow_definition.staff_step_names.map(&:to_s))
    }
    scope :open,   -> { where(status: :open) }
    scope :closed, -> { where(status: :closed).order(updated_at: :desc) }

    # Finds cases matching an event payload (by case_id or application_form_id).
    scope :for_event, ->(payload) {
      if payload[:case_id]
        where(id: payload[:case_id])
      elsif payload[:application_form_id]
        where(application_form_id: payload[:application_form_id])
      else
        none
      end
    }

    def state_machine
      @state_machine ||= self.class.state_machine_class.new(
        self,
        transition_class: Groundwork::WorkflowTransition,
        association_name: :workflow_transitions
      )
    end

    def close!
      self[:status] = :closed
      save!
    end

    def reopen!
      self[:status] = :open
      save!
    end

    def self.workflow_definition
      # Convention: PermitCase → PermitWorkflow
      name.sub("Case", "Workflow").constantize
    rescue NameError
      raise NotImplementedError, "#{name} must define a workflow. Create #{name.sub("Case", "Workflow")} or override .workflow_definition"
    end

    # Statesman machine class is generated per Case subclass (by the generator).
    # Convention: PermitCase → PermitCaseStateMachine
    def self.state_machine_class
      "#{name}StateMachine".constantize
    end

    def self.base_columns_for_migration
      %w[application_form_id:string current_step:string status:integer facts:jsonb]
    end
  end
end

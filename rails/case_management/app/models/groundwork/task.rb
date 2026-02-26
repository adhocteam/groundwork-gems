# frozen_string_literal: true

module Groundwork
  # Base class for all task types (STI). Tasks are units of work
  # attached to a Case, assigned to a specific actor type.
  #
  # The examiner queue is built on these scopes. The actionable scope
  # is the primary entry point for staff dashboards.
  class Task < ApplicationRecord
    self.abstract_class = false  # STI on this table

    belongs_to :case, polymorphic: true

    attribute :description,  :text
    attribute :due_on,       :date
    attribute :assignee_id,  :string
    attribute :notes,        :text

    protected attr_writer :assignee_id

    enum :status, { pending: 0, completed: 1 }, prefix: false

    validates :case, presence: true

    default_scope -> { order(due_on: :asc) }

    scope :due_today,     -> { where(due_on: Date.current) }
    scope :due_tomorrow,  -> { where(due_on: Date.tomorrow) }
    scope :due_this_week, -> { where(due_on: Date.current.beginning_of_week..Date.current.end_of_week) }
    scope :overdue,       -> { incomplete.where("due_on < ?", Date.current) }
    scope :incomplete,    -> { where.not(status: :completed) }
    scope :unassigned,    -> { where(assignee_id: nil) }
    scope :assigned_to,   ->(user_id) { where(assignee_id: user_id) }

    after_update :publish_status_changed, if: :saved_change_to_status?

    # Assigns the next unassigned incomplete task to a user, in a transaction
    # to prevent two examiners grabbing the same task.
    #
    # @param  user_id [String]
    # @return [Groundwork::Task, nil]
    def self.assign_next_to(user_id)
      transaction do
        task = incomplete.unassigned.lock.first
        return nil unless task

        task.assign(user_id)
        task
      end
    end

    def assign(user_id)
      self[:assignee_id] = user_id
      save!
    end

    def unassign
      self[:assignee_id] = nil
      save!
    end

    def complete!(notes: nil)
      self[:status] = :completed
      self[:notes]  = notes if notes
      save!
    end

    def incomplete?
      !completed?
    end

    def overdue?
      due_on.present? && due_on < Date.current && incomplete?
    end

    private

    def publish_status_changed
      CaseManagement::EventBus.publish(
        "#{self.class.name.demodulize}#{status.capitalize}",
        { task_id: id, case_id: case_id, case_type: case_type }
      )
    end
  end
end

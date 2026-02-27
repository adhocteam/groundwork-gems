# frozen_string_literal: true

class CreateGroundworkTables < ActiveRecord::Migration[7.2]
  def change
    # Groundwork::WorkflowTransition — Statesman audit trail
    create_table :groundwork_workflow_transitions do |t|
      t.string  :to_state,    null: false
      t.jsonb   :metadata,    null: false, default: {}
      t.integer :sort_key,    null: false
      t.boolean :most_recent, null: false
      t.uuid    :case_id,     null: false
      t.string  :case_type,   null: false

      t.timestamps null: false
    end

    add_index :groundwork_workflow_transitions,
              %i[case_type case_id most_recent],
              where: "most_recent",
              name:  "index_groundwork_transitions_on_case_and_most_recent"

    add_index :groundwork_workflow_transitions,
              %i[case_type case_id sort_key],
              unique: true,
              name:   "index_groundwork_transitions_on_case_and_sort_key"

    # Groundwork::Task (STI)
    create_table :groundwork_tasks do |t|
      t.string  :type,      null: false
      t.uuid    :case_id,   null: false
      t.string  :case_type, null: false
      t.string  :assignee_id
      t.integer :status,    null: false, default: 0
      t.date    :due_on
      t.text    :description
      t.text    :notes

      t.timestamps null: false
    end

    add_index :groundwork_tasks, %i[case_type case_id]

    add_index :groundwork_tasks, :assignee_id
    add_index :groundwork_tasks, :status
    add_index :groundwork_tasks, :due_on
  end
end


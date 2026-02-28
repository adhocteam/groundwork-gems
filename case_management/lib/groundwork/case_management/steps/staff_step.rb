# frozen_string_literal: true

module Groundwork
  module CaseManagement
    module Steps
      # Represents a step that requires action from a staff member.
      # Creates a Task record for the examiner queue when executed.
      class StaffStep
        attr_reader :name, :task_class

        def initialize(name, task_class)
          @name       = name.to_sym
          @task_class = task_class
        end

        def execute(kase)
          @task_class.create!(case: kase)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Groundwork
  module Forms
    # Evaluates navigation within a task given a record and current page index.
    class TaskEvaluator
      attr_reader :task, :record, :current_page_idx

      def initialize(task, record, current_page_idx)
        @task = task
        @record = record
        @current_page_idx = current_page_idx
      end

      def pages
        @task.pages
      end

      def current_page
        pages[@current_page_idx]
      end

      def prev_action
        idx = @current_page_idx - 1
        while idx >= 0
          page = pages[idx]
          return page.edit_action if page.needed?(@record)
          idx -= 1
        end
        nil
      end

      def update_action
        current_page.update_action
      end

      def next_action
        idx = @current_page_idx + 1
        while idx <= pages.length - 1
          page = pages[idx]
          return page.edit_action if page.needed?(@record)
          idx += 1
        end
        nil
      end
    end
  end
end


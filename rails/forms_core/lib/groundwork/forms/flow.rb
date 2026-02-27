# frozen_string_literal: true

module Groundwork
  module Forms
    # Defines a multi-page form flow as a set of tasks and pages.
    #
    # Core is intentionally Rails-agnostic: it models pages and returns action names
    # (e.g. "edit_name"), but does not compute URLs.
    module Flow
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def tasks
          @tasks ||= []
        end

        def contexts
          @contexts ||= []
        end

        def pages
          tasks.flat_map(&:pages)
        end

        def generated_actions
          pages.flat_map { |page| [page.edit_action, page.update_action] }
        end

        def task(task_name, &block)
          @current_task = Groundwork::Forms::Task.new(task_name)
          tasks.push(@current_task)
          block.call
          @current_task = nil
        end

        def question_page(page_name, if: nil, fields: nil)
          page = Groundwork::Forms::QuestionPage.new(page_name, if:, fields:)
          @current_task.pages.push(page)
          contexts.push(page_name)
        end

        def find_page_and_task_by_action(flow_record, action)
          tasks.each do |task|
            task.pages.each_with_index do |page, page_idx|
              if [page.edit_action.to_sym, page.update_action.to_sym].include?(action.to_sym)
                return page, Groundwork::Forms::TaskEvaluator.new(task, flow_record, page_idx)
              end
            end
          end

          [nil, nil]
        end
      end
    end
  end
end


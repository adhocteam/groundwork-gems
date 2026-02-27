# frozen_string_literal: true

module Groundwork
  module Forms
    # Represents a set of related pages in a flow.
    class Task
      attr_reader :name, :pages

      def initialize(name, pages: [])
        @name = name.to_sym
        @pages = pages
      end

      def started?(record)
        @pages.any? { |page| page.needed?(record) && page.completed?(record) }
      end

      def completed?(record)
        @pages.all? { |page| !page.needed?(record) || page.completed?(record) }
      end

      # Returns the edit action of the current workable page.
      def action(record)
        return nil if @pages.empty?

        workable_page =
          @pages.find { |page| page.needed?(record) && !page.completed?(record) } ||
          @pages.find { |page| page.needed?(record) } ||
          @pages.first

        workable_page&.edit_action
      end
    end
  end
end


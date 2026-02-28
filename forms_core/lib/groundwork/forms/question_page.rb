# frozen_string_literal: true

module Groundwork
  module Forms
    # Represents a single page in a flow.
    class QuestionPage
      attr_reader :name, :fields

      def initialize(name, if: nil, fields: nil)
        @name = name.to_sym
        @if = binding.local_variable_get(:if)
        @fields = fields || [@name]
      end

      def needed?(record)
        @if.nil? || @if.call(record)
      end

      def completed?(record)
        record.valid?(@name)
      end

      def edit_action
        "edit_#{@name}"
      end

      def update_action
        "update_#{@name}"
      end
    end
  end
end


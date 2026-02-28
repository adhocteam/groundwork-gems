# frozen_string_literal: true

module Groundwork
  module CaseManagement
    # DSL for defining a workflow: its steps, their actor types, and the
    # event-driven transitions between them.
    #
    # @example
    #   PermitWorkflow = Groundwork::CaseManagement::WorkflowDefinition.new do |w|
    #     w.applicant_step  :submit_application
    #     w.system_step     :prescreening,      PermitPrescreeningJob
    #     w.staff_step      :examiner_review,   PermitReviewTask
    #     w.staff_step      :make_determination, PermitDeterminationTask
    #
    #     w.on_start :submit_application
    #
    #     w.transition from: :submit_application, on: "PermitApplicationSubmitted", to: :prescreening
    #     w.transition from: :prescreening,       on: "PermitPrescreeningCleared",  to: :examiner_review
    #     w.transition from: :prescreening,       on: "PermitPrescreeningDenied",   to: :closed
    #     w.transition from: :examiner_review,    on: "PermitReviewComplete",       to: :make_determination
    #     w.transition from: :make_determination, on: "PermitApproved",             to: :closed
    #     w.transition from: :make_determination, on: "PermitDenied",               to: :closed
    #   end
    #
    class WorkflowDefinition
      attr_reader :steps, :transitions, :start_step

      def initialize(&block)
        @steps       = {}
        @transitions = {}  # { from_step => { event_name => to_step } }
        @start_step  = nil
        yield self if block_given?
      end

      # Declares which step the workflow begins on.
      def on_start(step_name)
        @start_step = step_name.to_sym
      end

      def applicant_step(name)
        @steps[name.to_sym] = Steps::ApplicantStep.new(name)
      end

      def staff_step(name, task_class)
        @steps[name.to_sym] = Steps::StaffStep.new(name, task_class)
      end

      def system_step(name, job_class)
        @steps[name.to_sym] = Steps::SystemStep.new(name, job_class)
      end

      def third_party_step(name)
        @steps[name.to_sym] = Steps::ThirdPartyStep.new(name)
      end

      # Registers an event-driven transition.
      #
      # @param from [Symbol]  source step name
      # @param on   [String]  event name that triggers the transition
      # @param to   [Symbol]  destination step name (or :closed)
      def transition(from:, on:, to:)
        @transitions[from.to_sym] ||= {}
        @transitions[from.to_sym][on.to_s] = to.to_sym
      end

      # Returns step names that require staff action.
      def staff_step_names
        @steps.select { |_, step| step.is_a?(Steps::StaffStep) }.keys
      end

      # Returns all event names this workflow listens for.
      def event_names
        @transitions.values.flat_map(&:keys).uniq
      end

      # Returns the next step for a given current step + event, or nil.
      def next_step(current_step, event_name)
        @transitions.dig(current_step.to_sym, event_name.to_s)
      end

      # Renders a Mermaid flowchart for documentation.
      def to_mermaid
        lines = ["flowchart TD"]
        @steps.each do |name, step|
          lines << "  #{name}:::#{step.class.name.demodulize}"
        end
        lines << "  closed((Closed))"
        @transitions.each do |from, events|
          events.each do |event, to|
            to_label = to == :closed ? "closed" : to
            lines << "  #{from} -->|#{event}| #{to_label}"
          end
        end
        lines << "classDef ApplicantStep fill:#90EE90,stroke:#333;"
        lines << "classDef StaffStep fill:#ffb366,stroke:#333;"
        lines << "classDef SystemStep fill:#a0d8ef,stroke:#333;"
        lines << "classDef ThirdPartyStep fill:#c0c0ff,stroke:#333;"
        lines.join("\n")
      end
    end
  end
end

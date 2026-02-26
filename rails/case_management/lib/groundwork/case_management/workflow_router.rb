# frozen_string_literal: true

module Groundwork
  module CaseManagement
    # Base class for workflow process managers.
    #
    # A WorkflowRouter subscribes to RailsEventStore events and drives
    # case workflow transitions in response. Subclass it once per workflow.
    #
    # @example
    #   class PermitWorkflowRouter < Groundwork::CaseManagement::WorkflowRouter
    #     workflow  PermitWorkflow
    #     case_class PermitCase
    #
    #     # Override to customize case creation on the start event
    #     def build_case(event)
    #       PermitCase.new(application_form_id: event.data[:application_form_id])
    #     end
    #   end
    #
    #   # Register in config/initializers/groundwork.rb:
    #   PermitWorkflowRouter.register!
    #
    class WorkflowRouter
      @registered = []

      class << self
        attr_reader :registered

        def workflow(definition)
          @workflow_definition = definition
        end

        def case_class(klass)
          @case_class = klass
        end

        def workflow_definition
          @workflow_definition || raise(NotImplementedError, "#{name} must declare `workflow <WorkflowDefinition>`")
        end

        def kase_class
          @case_class || raise(NotImplementedError, "#{name} must declare `case_class <CaseClass>`")
        end

        # Registers this router so the Engine subscribes it on boot.
        def register!
          WorkflowRouter.registered << self unless WorkflowRouter.registered.include?(self)
        end

        # Called by the Engine after initialization to wire up RES subscriptions.
        def subscribe!
          instance = new
          workflow_definition.event_names.each do |event_name|
            EventBus.subscribe(event_name, instance)
          end
        end
      end

      # RailsEventStore calls this when a subscribed event is published.
      def call(event)
        event_name = event.class.name.demodulize

        if start_event?(event_name)
          handle_start_event(event)
        else
          handle_transition_event(event, event_name)
        end
      end

      private

      def workflow
        self.class.workflow_definition
      end

      def start_event?(event_name)
        start_step = workflow.start_step
        return false unless start_step

        workflow.transitions.none? { |_, events| events.value?(start_step) } &&
          workflow.transitions[start_step]&.key?(event_name)
      end

      def handle_start_event(event)
        kase = build_case(event)
        kase.save!
        advance(kase, event.class.name.demodulize)
      end

      def handle_transition_event(event, event_name)
        cases = self.class.kase_class.for_event(event.data)
        cases.each { |kase| advance(kase, event_name) }
      end

      def advance(kase, event_name)
        next_step = workflow.next_step(kase.current_step, event_name)
        return unless next_step

        kase.state_machine.transition_to!(next_step, event_name: event_name)
        kase.current_step = next_step
        kase.save!

        execute_step(kase, next_step)
      end

      def execute_step(kase, step_name)
        return kase.close! if step_name == :closed

        step = workflow.steps[step_name]
        step&.execute(kase)
      rescue StandardError => e
        Rails.logger.error "[Groundwork] Error executing step #{step_name} for case #{kase.id}: #{e.message}"
        raise
      end

      # Override in subclasses to customize case construction from start event.
      def build_case(event)
        self.class.kase_class.new(application_form_id: event.data[:application_form_id])
      end
    end
  end
end

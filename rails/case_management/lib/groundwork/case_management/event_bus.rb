# frozen_string_literal: true

module Groundwork
  module CaseManagement
    # Thin wrapper around the host app's RailsEventStore client.
    # Provides a stable interface so application code doesn't call
    # Rails.configuration.event_store directly.
    module EventBus
      # Publishes a named event with an arbitrary payload.
      #
      # @param event_name [String]  e.g. "FelApplicationSubmitted"
      # @param payload    [Hash]    e.g. { case_id: 42, submitted_at: Time.current }
      def self.publish(event_name, payload = {})
        event_class = event_class_for(event_name)
        Rails.configuration.event_store.publish(event_class.new(data: payload))
      end

      # Subscribes a callable to a named event.
      # Primarily used by WorkflowRouter — prefer subclassing WorkflowRouter
      # over calling this directly.
      #
      # @param event_name [String]
      # @param handler    [#call]
      def self.subscribe(event_name, handler)
        event_class = event_class_for(event_name)
        Rails.configuration.event_store.subscribe(handler, to: [event_class])
      end

      private_class_method def self.event_class_for(event_name)
        # Dynamically resolve or create a RailsEventStore::Event subclass
        # scoped under Groundwork::Events so host apps can also define named event classes.
        const_name = "Groundwork::Events::#{event_name}"
        begin
          const_name.constantize
        rescue NameError
          klass = Class.new(RailsEventStore::Event)
          Groundwork::Events.const_set(event_name, klass)
          klass
        end
      end
    end

    # Namespace for auto-generated event classes.
    module Events; end
  end
end

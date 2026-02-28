# frozen_string_literal: true

module Groundwork
  module CaseManagement
    module Steps
      # Represents a step awaiting a submission from a third party
      # (e.g. an employer, healthcare provider, or external agency).
      # No automatic execution — the step waits for an inbound event.
      class ThirdPartyStep
        attr_reader :name

        def initialize(name)
          @name = name.to_sym
        end

        def execute(_kase)
          # No-op: driven by inbound webhook/event from third party
        end
      end
    end
  end
end

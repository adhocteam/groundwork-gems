# frozen_string_literal: true

module Groundwork
  module CaseManagement
    module Steps
      # Represents a step where the applicant submits a form.
      # No automatic execution — the applicant drives this step via the UI.
      class ApplicantStep
        attr_reader :name

        def initialize(name)
          @name = name.to_sym
        end

        def execute(_kase)
          # No-op: applicant action; driven by form submission
        end
      end
    end
  end
end

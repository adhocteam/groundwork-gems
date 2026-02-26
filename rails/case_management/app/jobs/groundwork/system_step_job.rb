# frozen_string_literal: true

module Groundwork
  # Base job for system steps. Subclass this for each automated workflow step.
  #
  # @example
  #   class PermitPrescreeningJob < Groundwork::SystemStepJob
  #     def perform(case_id)
  #       kase = PermitCase.find(case_id)
  #       result = PrescreeningService.check(kase.application_form)
  #
  #       event = result.cleared? ? "PermitPrescreeningCleared" : "PermitPrescreeningDenied"
  #       Groundwork::CaseManagement::EventBus.publish(event, case_id: case_id)
  #     end
  #   end
  class SystemStepJob < ApplicationJob
    queue_as :default

    # Subclasses must implement perform(case_id).
    def perform(*)
      raise NotImplementedError, "#{self.class.name} must implement #perform(case_id)"
    end
  end
end

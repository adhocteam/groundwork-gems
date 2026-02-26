# frozen_string_literal: true

module Groundwork
  module CaseManagement
    module Steps
      # Represents an automated step executed by a background job.
      # Dispatches the job asynchronously so integrations (NICS, Pay.gov, etc.)
      # never block web requests.
      class SystemStep
        attr_reader :name, :job_class

        def initialize(name, job_class)
          @name      = name.to_sym
          @job_class = job_class
        end

        def execute(kase)
          @job_class.perform_later(kase.id)
        end
      end
    end
  end
end

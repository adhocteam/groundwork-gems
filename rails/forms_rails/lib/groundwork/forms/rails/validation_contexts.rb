# frozen_string_literal: true

module Groundwork
  module Forms
    module Rails
      # Helper for defining validation context constants for a flow.
      #
      # This is intentionally light-weight: apps choose whether (and how) to
      # validate all contexts on submit.
      module ValidationContexts
        extend ActiveSupport::Concern

        class_methods do
          module Flow
          end

          def define_flow_contexts(flow_class)
            flow_class.contexts.each do |context|
              const_name = context.to_s.upcase.to_sym
              Flow.const_set(const_name, context) unless Flow.const_defined?(const_name)
            end
          end
        end
      end
    end
  end
end


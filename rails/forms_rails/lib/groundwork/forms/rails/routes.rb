# frozen_string_literal: true

module Groundwork
  module Forms
    module Rails
      # Route helper for generating per-page member routes from a flow.
      #
      # @example
      #   resources :applications do
      #     groundwork_flow MyApplicationFlow
      #   end
      module Routes
        def groundwork_flow(flow_class)
          flow_class.pages.each do |page|
            get page.edit_action, on: :member
            patch page.update_action, on: :member
          end
        end
      end
    end
  end
end

ActionDispatch::Routing::Mapper.include(Groundwork::Forms::Rails::Routes)


# frozen_string_literal: true

module Groundwork
  module Forms
    module Rails
      # Rails controller integration for per-page edit/update actions defined by a Flow.
      module ApplicationFormController
        extend ActiveSupport::Concern

        def flow_record
          raise NotImplementedError, "#{self.class.name} must define #flow_record"
        end

        class_methods do
          def flow(flow_class)
            before_action :set_flow
            before_action :set_flow_task, only: flow_class.generated_actions.map(&:to_sym)

            define_method(:set_flow) do
              @flow = flow_class
            end

            define_method(:set_flow_task) do
              @flow_page, @flow_task = flow_class.find_page_and_task_by_action(
                flow_record,
                request.path_parameters[:action]
              )
            end

            flow_class.pages.each do |page|
              define_method(page.edit_action) do
              end

              define_method(page.update_action) do
                record_key = flow_record.class.name.underscore.to_sym
                form_params =
                  if page.fields.empty?
                    ActionController::Parameters.new({})
                  else
                    params.require(record_key).permit(*(page.fields))
                  end

                flow_record.assign_attributes(form_params)

                if flow_record.valid?(page.name) && flow_record.save(context: page.name)
                  next_action = @flow_task&.next_action
                  redirect_to action: (next_action || "show"), id: flow_record.id
                else
                  # Allow custom error-handling behaviors by defining :on_flow_update_invalid
                  on_flow_update_invalid if respond_to?(:on_flow_update_invalid)
                  render page.edit_action, status: :unprocessable_entity
                end
              end
            end
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

require "groundwork/case_management/event_bus"
require "groundwork/case_management/workflow_definition"
require "groundwork/case_management/workflow_router"
require "groundwork/case_management/steps/applicant_step"
require "groundwork/case_management/steps/staff_step"
require "groundwork/case_management/steps/system_step"
require "groundwork/case_management/steps/third_party_step"

module Groundwork
  module CaseManagement
    class Engine < ::Rails::Engine
      isolate_namespace Groundwork

      config.generators do |g|
        g.test_framework :rspec
        g.fixture_replacement :factory_bot, dir: "spec/factories"
      end

      initializer "groundwork.statesman" do
        Statesman.configure do
          storage_adapter Statesman::Adapters::ActiveRecord
        end
      end

      initializer "groundwork.event_store" do |app|
        # Configure RailsEventStore if not already configured by the host app.
        # Host apps can override this in their own initializer before this runs.
        unless app.config.respond_to?(:event_store) && app.config.event_store.present?
          require "rails_event_store"
          app.config.event_store = RailsEventStore::Client.new
        end
      end

      initializer "groundwork.workflow_routers" do
        # Allow host apps to register WorkflowRouter subclasses.
        # Routers subscribe to RailsEventStore in an after_initialize block
        # so all classes are loaded first.
        ActiveSupport.on_load(:after_initialize) do
          Groundwork::CaseManagement::WorkflowRouter.registered.each(&:subscribe!)
        end
      end
    end
  end
end

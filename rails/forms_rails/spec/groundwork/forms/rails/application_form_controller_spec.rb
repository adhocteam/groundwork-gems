# frozen_string_literal: true

require "spec_helper"

RSpec.describe Groundwork::Forms::Rails::ApplicationFormController do
  class FlowRecord
    attr_reader :id, :assigned, :saved_context

    def initialize(id: "id-1")
      @id = id
    end

    def assign_attributes(attrs)
      @assigned = attrs
    end

    def valid?(_context = nil)
      true
    end

    def save(context: nil)
      @saved_context = context
      true
    end
  end

  class ExampleFlow
    include Groundwork::Forms::Flow

    task :t1 do
      question_page :a, fields: %i[a]
      question_page :c, fields: %i[c]
    end
  end

  class DummyController < ActionController::Base
    include Groundwork::Forms::Rails::ApplicationFormController

    flow ExampleFlow

    attr_accessor :record, :test_params, :redirected_to, :rendered

    def flow_record
      record
    end

    def params
      test_params || super
    end

    def redirect_to(options = nil, **kwargs)
      self.redirected_to = options || kwargs
    end

    def render(*args, **kwargs)
      self.rendered = [args, kwargs]
    end
  end

  it "defines per-page edit and update actions" do
    expect(DummyController.instance_methods).to include(:edit_a, :update_a, :edit_c, :update_c)
  end

  it "permits only the page fields and saves in the page context" do
    controller = DummyController.new
    controller.record = FlowRecord.new

    page, task = ExampleFlow.find_page_and_task_by_action(controller.record, :update_a)
    controller.instance_variable_set(:@flow_page, page)
    controller.instance_variable_set(:@flow_task, task)
    controller.instance_variable_set(:@flow, ExampleFlow)

    controller.test_params = ActionController::Parameters.new(
      flow_record: { a: "ok", c: "nope" }
    )

    controller.update_a

    expect(controller.record.assigned.to_h).to eq({ "a" => "ok" })
    expect(controller.record.saved_context).to eq(:a)
    expect(controller.redirected_to).to include(action: "edit_c")
  end

  it "does not require params for pages with no fields" do
    class ReviewFlow
      include Groundwork::Forms::Flow

      task :t1 do
        question_page :review, fields: []
      end
    end

    class ReviewController < ActionController::Base
      include Groundwork::Forms::Rails::ApplicationFormController

      flow ReviewFlow

      attr_accessor :record, :test_params, :redirected_to, :rendered

      def flow_record
        record
      end

      def params
        test_params || super
      end

      def redirect_to(options = nil, **kwargs)
        self.redirected_to = options || kwargs
      end

      def render(*args, **kwargs)
        self.rendered = [args, kwargs]
      end
    end

    controller = ReviewController.new
    controller.record = FlowRecord.new

    page, task = ReviewFlow.find_page_and_task_by_action(controller.record, :update_review)
    controller.instance_variable_set(:@flow_page, page)
    controller.instance_variable_set(:@flow_task, task)
    controller.instance_variable_set(:@flow, ReviewFlow)

    controller.test_params = ActionController::Parameters.new({})

    expect { controller.update_review }.not_to raise_error
    expect(controller.redirected_to).to include(action: "show")
  end
end

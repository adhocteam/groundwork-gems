# frozen_string_literal: true

require "groundwork-forms_core"

RSpec.describe "Groundwork::Forms::Flow" do
  class FlowRecord
    def initialize(needed_pages:, completed_pages:)
      @needed_pages = needed_pages
      @completed_pages = completed_pages
    end

    def needed_pages
      @needed_pages
    end

    def valid?(context = nil)
      @completed_pages.include?(context.to_sym)
    end
  end

  class ExampleFlow
    include Groundwork::Forms::Flow

    task :t1 do
      question_page :a
      question_page :b, if: ->(record) { record.needed_pages.include?(:b) }
      question_page :c
    end
  end

  it "generates edit/update action names for pages" do
    expect(ExampleFlow.generated_actions).to include("edit_a", "update_a", "edit_c", "update_c")
  end

  it "skips unneeded pages when navigating to next_action" do
    record = FlowRecord.new(needed_pages: [], completed_pages: %i[a])
    page, task = ExampleFlow.find_page_and_task_by_action(record, :edit_a)

    expect(page.name).to eq(:a)
    expect(task.next_action).to eq("edit_c")
  end

  it "returns nil next_action at the end of the task" do
    record = FlowRecord.new(needed_pages: %i[b], completed_pages: %i[a b c])
    _page, task = ExampleFlow.find_page_and_task_by_action(record, :edit_c)

    expect(task.next_action).to be_nil
  end
end


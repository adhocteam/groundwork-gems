# frozen_string_literal: true

require "spec_helper"

RSpec.describe Groundwork::CaseManagement::WorkflowDefinition do
  let(:stub_job)  { Class.new }
  let(:stub_task) { Class.new }

  subject(:workflow) do
    described_class.new do |w|
      w.applicant_step  :submit_application
      w.system_step     :prescreening, stub_job
      w.staff_step      :examiner_review, stub_task
      w.staff_step      :make_determination, stub_task

      w.on_start :submit_application

      w.transition from: :submit_application, on: "ApplicationSubmitted",   to: :prescreening
      w.transition from: :prescreening,       on: "PrescreeningCleared",    to: :examiner_review
      w.transition from: :prescreening,       on: "PrescreeningDenied",     to: :closed
      w.transition from: :examiner_review,    on: "ReviewComplete",         to: :make_determination
      w.transition from: :make_determination, on: "Approved",               to: :closed
      w.transition from: :make_determination, on: "Denied",                 to: :closed
    end
  end

  it "registers all steps" do
    expect(workflow.steps.keys).to contain_exactly(
      :submit_application, :prescreening, :examiner_review, :make_determination
    )
  end

  it "identifies staff step names" do
    expect(workflow.staff_step_names).to contain_exactly(:examiner_review, :make_determination)
  end

  it "resolves the next step for a given event" do
    expect(workflow.next_step(:prescreening, "PrescreeningCleared")).to eq(:examiner_review)
    expect(workflow.next_step(:prescreening, "PrescreeningDenied")).to eq(:closed)
  end

  it "returns nil for an unknown event" do
    expect(workflow.next_step(:prescreening, "UnknownEvent")).to be_nil
  end

  it "collects all event names" do
    expect(workflow.event_names).to include(
      "ApplicationSubmitted", "PrescreeningCleared", "PrescreeningDenied",
      "ReviewComplete", "Approved", "Denied"
    )
  end

  it "renders a mermaid diagram" do
    diagram = workflow.to_mermaid
    expect(diagram).to start_with("flowchart TD")
    expect(diagram).to include("submit_application")
    expect(diagram).to include("PrescreeningCleared")
  end
end

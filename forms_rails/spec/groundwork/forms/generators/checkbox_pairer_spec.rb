# frozen_string_literal: true

require "spec_helper"
require "groundwork/forms/generators/checkbox_pairer"

RSpec.describe Groundwork::Forms::Generators::CheckboxPairer do
  subject(:pairer) { described_class.new }

  def checkbox(id:, page:, tooltip:)
    { "id" => id, "kind" => "checkbox", "page" => page,
      "pdf" => { "tu" => tooltip }, "label" => { "text" => "" } }
  end

  def text_field(id:, page:)
    { "id" => id, "kind" => "text", "page" => page,
      "pdf" => { "tu" => id }, "label" => { "text" => id } }
  end

  it "collapses a yes/no pair into one field (the first)" do
    fields = [
      checkbox(id: "CB1", page: 1, tooltip: "3. Licensed? Yes"),
      checkbox(id: "CB2", page: 1, tooltip: "3. Licensed? No")
    ]
    result = pairer.call(fields)
    expect(result.length).to eq(1)
    expect(result.first["id"]).to eq("CB1")
    expect(result.first["_paired"]).to be(true)
  end

  it "leaves a standalone checkbox alone" do
    fields = [checkbox(id: "CB1", page: 1, tooltip: "Subscribe")]
    result = pairer.call(fields)
    expect(result.length).to eq(1)
    expect(result.first["_paired"]).to be_nil
  end

  it "does not pair checkboxes on different pages" do
    fields = [
      checkbox(id: "CB1", page: 1, tooltip: "Has license? Yes"),
      checkbox(id: "CB2", page: 2, tooltip: "Has license? No")
    ]
    result = pairer.call(fields)
    expect(result.length).to eq(2)
  end

  it "does not pair non-adjacent yes/no checkboxes" do
    fields = [
      checkbox(id: "CB1", page: 1, tooltip: "Question A: Yes"),
      text_field(id: "TF1", page: 1),
      checkbox(id: "CB2", page: 1, tooltip: "Question A: No")
    ]
    result = pairer.call(fields)
    expect(result.length).to eq(3)
  end

  it "handles multiple pairs in the same field list" do
    fields = [
      checkbox(id: "CB1", page: 1, tooltip: "Q1: Yes"),
      checkbox(id: "CB2", page: 1, tooltip: "Q1: No"),
      checkbox(id: "CB3", page: 1, tooltip: "Q2: Yes"),
      checkbox(id: "CB4", page: 1, tooltip: "Q2: No")
    ]
    result = pairer.call(fields)
    expect(result.length).to eq(2)
    expect(result.map { |f| f["id"] }).to eq(["CB1", "CB3"])
  end
end

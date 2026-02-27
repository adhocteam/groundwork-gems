# frozen_string_literal: true

require "spec_helper"
require "groundwork/forms/generators/type_mapper"

RSpec.describe Groundwork::Forms::Generators::TypeMapper do
  subject(:mapper) { described_class.new }

  def field(kind:, multiline: false)
    { "kind" => kind, "pdf" => { "flags" => { "multiline" => multiline } } }
  end

  it "maps a single-line text field to :string" do
    expect(mapper.call(field(kind: "text", multiline: false))).to eq(:string)
  end

  it "maps a multiline text field to :text" do
    expect(mapper.call(field(kind: "text", multiline: true))).to eq(:text)
  end

  it "maps a checkbox to :boolean" do
    expect(mapper.call(field(kind: "checkbox"))).to eq(:boolean)
  end

  it "maps a signature field to :skip" do
    expect(mapper.call(field(kind: "signature"))).to eq(:skip)
  end

  it "maps unknown kinds to :string as a safe default" do
    expect(mapper.call(field(kind: "barcode"))).to eq(:string)
  end
end

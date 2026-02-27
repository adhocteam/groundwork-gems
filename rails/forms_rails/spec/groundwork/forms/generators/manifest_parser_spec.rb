# frozen_string_literal: true

require "spec_helper"
require "groundwork/forms/generators/manifest_parser"

RSpec.describe Groundwork::Forms::Generators::ManifestParser do
  let(:fields_path)  { File.expand_path("../../../fixtures/form-fields.json", __dir__) }
  let(:journey_path) { File.expand_path("../../../fixtures/runtime-guards.json", __dir__) }

  subject(:result) { described_class.call(fields_path: fields_path, journey_path: journey_path) }

  it "returns step IDs in order from the journey" do
    expect(result.steps).to eq(["start", "review-submit"])
  end

  it "returns the page numbers present in the form" do
    expect(result.pages).to eq([1, 2])
  end

  it "groups fields by page" do
    expect(result.fields_by_page.keys).to eq([1, 2])
  end

  it "page 1 has the expected number of fields (5 raw, before pairing)" do
    # 3 text + 2 checkboxes + 1 signature = 6 raw fields on page 1
    expect(result.fields_by_page[1].length).to eq(6)
  end

  it "page 2 has 1 field" do
    expect(result.fields_by_page[2].length).to eq(1)
  end

  it "fields are plain hashes with expected keys" do
    field = result.fields_by_page[1].first
    expect(field.keys).to include("id", "kind", "page", "pdf", "label")
  end

  it "raises an error when form-fields.json is missing the 'fields' key" do
    bad_json = Tempfile.new(["bad-fields", ".json"])
    bad_json.write('{"source": {}}')
    bad_json.flush

    expect {
      described_class.call(fields_path: bad_json.path, journey_path: journey_path)
    }.to raise_error(Groundwork::Forms::Generators::ManifestParser::Error, /malformed manifest/)

    bad_json.close
    bad_json.unlink
  end
end

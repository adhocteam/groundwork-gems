# frozen_string_literal: true

require "spec_helper"

RSpec.describe Groundwork::GovernmentAttributes::Address do
  subject(:address) do
    described_class.new(
      street_line_1: "123 Main St",
      city:          "Springfield",
      state:         "IL",
      zip_code:      "62701"
    )
  end

  it "is valid with all required fields" do
    expect(address).to be_valid
  end

  it "formats to a single-line string" do
    expect(address.to_s).to eq("123 Main St, Springfield, IL 62701")
  end

  it "includes street_line_2 when present" do
    address.street_line_2 = "Suite 100"
    expect(address.to_s).to include("Suite 100")
  end

  describe "validation" do
    it "is invalid without street_line_1" do
      address.street_line_1 = nil
      expect(address).not_to be_valid
    end

    it "is invalid with a state longer than 2 characters" do
      address.state = "Illinois"
      expect(address).not_to be_valid
    end

    it "is invalid with a malformed zip code" do
      address.zip_code = "not-a-zip"
      expect(address).not_to be_valid
    end

    it "accepts ZIP+4 format" do
      address.zip_code = "62701-1234"
      expect(address).to be_valid
    end
  end

  describe "equality" do
    it "equals another Address with the same values" do
      other = described_class.new(address.attributes)
      expect(address).to eq(other)
    end

    it "does not equal an Address with different values" do
      other = described_class.new(address.attributes.merge("city" => "Shelbyville"))
      expect(address).not_to eq(other)
    end
  end
end

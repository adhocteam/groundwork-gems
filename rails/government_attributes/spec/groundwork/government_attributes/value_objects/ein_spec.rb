# frozen_string_literal: true

require "spec_helper"

RSpec.describe Groundwork::GovernmentAttributes::Ein do
  describe "construction" do
    it "strips dashes on initialization" do
      expect(described_class.new("12-3456789").digits).to eq("123456789")
    end

    it "accepts a plain 9-digit string" do
      expect(described_class.new("123456789").digits).to eq("123456789")
    end
  end

  describe "#to_s" do
    it "formats as XX-XXXXXXX" do
      expect(described_class.new("123456789").to_s).to eq("12-3456789")
    end

    it "returns empty string for nil" do
      expect(described_class.new(nil).to_s).to eq("")
    end
  end

  describe "validation" do
    it "is valid with 9 digits" do
      expect(described_class.new("123456789")).to be_valid
    end

    it "is invalid with fewer than 9 digits" do
      ein = described_class.new("12345678")
      expect(ein).not_to be_valid
    end

    it "is invalid with letters" do
      ein = described_class.new("1234567AB")
      expect(ein).not_to be_valid
    end
  end
end

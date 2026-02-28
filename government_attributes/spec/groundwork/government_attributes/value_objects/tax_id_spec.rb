# frozen_string_literal: true

require "spec_helper"

RSpec.describe Groundwork::GovernmentAttributes::TaxId do
  describe "construction" do
    it "strips dashes on initialization" do
      expect(described_class.new("123-45-6789").digits).to eq("123456789")
    end

    it "accepts a plain 9-digit string" do
      expect(described_class.new("123456789").digits).to eq("123456789")
    end
  end

  describe "#to_s" do
    it "formats as XXX-XX-XXXX" do
      expect(described_class.new("123456789").to_s).to eq("123-45-6789")
    end
  end

  describe "#masked" do
    it "masks all but the last 4 digits" do
      expect(described_class.new("123456789").masked).to eq("XXX-XX-6789")
    end
  end

  describe "validation" do
    it "is valid with 9 digits" do
      expect(described_class.new("123456789")).to be_valid
    end

    it "is invalid with 8 digits" do
      expect(described_class.new("12345678")).not_to be_valid
    end
  end
end

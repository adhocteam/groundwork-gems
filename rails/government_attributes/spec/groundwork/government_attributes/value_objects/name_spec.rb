# frozen_string_literal: true

require "spec_helper"

RSpec.describe Groundwork::GovernmentAttributes::Name do
  subject(:name) { described_class.new(first: "Jane", last: "Smith") }

  it "is valid with first and last" do
    expect(name).to be_valid
  end

  describe "#full_name" do
    it "returns first and last" do
      expect(name.full_name).to eq("Jane Smith")
    end

    it "includes middle name when present" do
      name.middle = "Marie"
      expect(name.full_name).to eq("Jane Marie Smith")
    end

    it "includes suffix when present" do
      name.suffix = "Jr."
      expect(name.full_name).to eq("Jane Smith Jr.")
    end
  end

  describe "validation" do
    it "is invalid without first name" do
      name.first = nil
      expect(name).not_to be_valid
    end

    it "is invalid without last name" do
      name.last = nil
      expect(name).not_to be_valid
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe Groundwork::GovernmentAttributes::Money do
  describe "construction" do
    it "accepts an integer as cents" do
      expect(described_class.new(1250).cents).to eq(1250)
    end

    it "accepts a hash with a :cents key" do
      expect(described_class.new(cents: 500).cents).to eq(500)
    end

    it "raises on invalid input" do
      expect { described_class.new("not money") }.to raise_error(ArgumentError)
    end
  end

  describe "#dollar_amount" do
    it "converts cents to dollars" do
      expect(described_class.new(1250).dollar_amount).to eq(BigDecimal("12.5"))
    end
  end

  describe "#to_s" do
    it "formats as currency" do
      expect(described_class.new(1000).to_s).to eq("$10.00")
    end
  end

  describe "arithmetic" do
    let(:ten)  { described_class.new(1000) }
    let(:five) { described_class.new(500) }

    it "adds two Money values" do
      expect((ten + five).cents).to eq(1500)
    end

    it "subtracts two Money values" do
      expect((ten - five).cents).to eq(500)
    end

    it "multiplies by a scalar" do
      expect((ten * 2).cents).to eq(2000)
    end

    it "divides by a scalar (floors to nearest cent)" do
      expect((ten / 3).cents).to eq(333)
    end

    it "raises TypeError when adding non-Money" do
      expect { ten + 500 }.to raise_error(TypeError)
    end
  end

  describe "comparison" do
    it "is comparable" do
      expect(described_class.new(100)).to be < described_class.new(200)
    end
  end
end

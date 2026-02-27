# frozen_string_literal: true

require "spec_helper"
require "groundwork/forms/generators/field_deriver"

RSpec.describe Groundwork::Forms::Generators::FieldDeriver do
  subject(:deriver) { described_class.new }

  describe "#call" do
    it "strips a leading ordinal prefix" do
      expect(deriver.call("1. Name of Applicant")).to eq("name_applicant")
    end

    it "strips parentheticals" do
      expect(deriver.call("Trade Name (DBA)")).to eq("trade_name")
    end

    it "strips ordinal AND parenthetical" do
      expect(deriver.call("2. Trade Name (DBA)")).to eq("trade_name")
    end

    it "takes at most 3 significant words" do
      expect(deriver.call("Date of Birth Certificate Number Record")).to eq("date_birth_certificate")
    end

    it "skips filler words (of, the, a, an, and, or, in, for, to)" do
      expect(deriver.call("Name of Applicant")).to eq("name_applicant")
    end

    it "handles a plain word with no transformations needed" do
      expect(deriver.call("Phone")).to eq("phone")
    end

    it "falls back gracefully on an empty string" do
      expect(deriver.call("")).to eq("")
    end
  end

  describe "#call_all" do
    it "deduplicates colliding names by appending _2, _3" do
      expect(deriver.call_all(["Phone", "Phone", "Phone"]))
        .to eq(["phone", "phone_2", "phone_3"])
    end

    it "does not rename a name that only appears once" do
      expect(deriver.call_all(["Phone", "Email"]))
        .to eq(["phone", "email"])
    end

    it "deduplicates even across different source labels that map to the same name" do
      # "Name Applicant" and "1. Name of Applicant (LLC)" both → "name_applicant"
      expect(deriver.call_all(["Name Applicant", "1. Name of Applicant (LLC)"]))
        .to eq(["name_applicant", "name_applicant_2"])
    end
  end
end

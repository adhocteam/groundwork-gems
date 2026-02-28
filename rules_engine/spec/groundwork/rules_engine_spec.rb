# frozen_string_literal: true

require "spec_helper"

RSpec.describe Groundwork::RulesEngine do
  let(:ruleset) do
    Class.new do
      def eligible?(prescreening_cleared, license_type_valid)
        prescreening_cleared && license_type_valid
      end

      def license_type_valid(license_type)
        %w[limited_permit user_permit].include?(license_type)
      end

      def prescreening_cleared(prescreening_status)
        prescreening_status == :cleared
      end
    end.new
  end

  subject(:engine) { described_class.new(ruleset) }

  describe "#evaluate" do
    context "when all input facts are set and eligibility is met" do
      before do
        engine.set_facts(
          license_type:        "limited_permit",
          prescreening_status: :cleared
        )
      end

      it "returns true for :eligible?" do
        expect(engine.evaluate(:eligible?).value).to be true
      end

      it "builds a reasons tree" do
        result = engine.evaluate(:eligible?)
        reason_names = result.reasons.map(&:name)
        expect(reason_names).to contain_exactly(:prescreening_cleared, :license_type_valid)
      end
    end

    context "when prescreening is denied" do
      before do
        engine.set_facts(
          license_type:        "limited_permit",
          prescreening_status: :denied
        )
      end

      it "returns false for :eligible?" do
        expect(engine.evaluate(:eligible?).value).to be false
      end
    end

    context "when license type is invalid" do
      before do
        engine.set_facts(
          license_type:        "unknown_type",
          prescreening_status: :cleared
        )
      end

      it "returns false for :eligible?" do
        expect(engine.evaluate(:eligible?).value).to be false
      end
    end

    context "when a required input fact is missing" do
      before { engine.set_facts(license_type: "limited_permit") }

      it "returns nil for the unknown fact" do
        expect(engine.evaluate(:prescreening_cleared).value).to be_nil
      end

      it "marks the fact as unknown" do
        expect(engine.evaluate(:prescreening_cleared)).to be_unknown
      end
    end

    context "when a rule does not exist on the ruleset" do
      it "returns a Fact with nil value" do
        engine.set_facts({})
        result = engine.evaluate(:nonexistent_fact)
        expect(result.value).to be_nil
      end
    end

    it "caches evaluated facts" do
      engine.set_facts(license_type: "limited_permit", prescreening_status: :cleared)
      first  = engine.evaluate(:license_type_valid)
      second = engine.evaluate(:license_type_valid)
      expect(first).to be(second)
    end
  end

  describe "#set_facts" do
    it "accepts symbol keys" do
      engine.set_facts(license_type: "limited_permit")
      expect(engine.evaluate(:license_type_valid).value).to be true
    end

    it "accepts string keys" do
      engine.set_facts("license_type" => "limited_permit")
      expect(engine.evaluate(:license_type_valid).value).to be true
    end
  end
end

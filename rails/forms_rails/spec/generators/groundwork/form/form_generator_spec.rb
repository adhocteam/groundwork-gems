# frozen_string_literal: true

require "spec_helper"
require "rails/generators"
require "generators/groundwork/form/form_generator"

RSpec.describe Groundwork::Generators::FormGenerator do
  let(:destination) { File.expand_path("../../../../tmp/generators", __dir__) }

  let(:fixture_fields)  { File.expand_path("../../../fixtures/form-fields.json", __dir__) }
  let(:fixture_journey) { File.expand_path("../../../fixtures/runtime-guards.json", __dir__) }

  around do |example|
    FileUtils.rm_rf(destination)
    FileUtils.mkdir_p(destination)
    example.run
    FileUtils.rm_rf(destination)
  end

  def capture_stdout
    old_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = old_stdout
  end

  def stub_ask_responses
    # Thor's ask delegates to Thor::LineEditor.readline; stub at that level
    # to avoid RSpec any_instance arity conflicts with Thor's method_eval-defined ask.
    # Return "1" for the 'start' step so page 1 is assigned, "" for all others.
    allow(Thor::LineEditor).to receive(:readline) do |prompt, _opts|
      prompt.include?("'start'") ? "1" : ""
    end
  end

  def stub_sub_generators
    # Wrap Rails::Generators.invoke to suppress nested generator calls
    # (avoids any_instance arity issues where RSpec aliases become Thor actions)
    allow(Rails::Generators).to receive(:invoke).and_wrap_original do |original, name, *rest|
      next nil if name.to_s == "groundwork:application_form"
      original.call(name, *rest)
    end
  end

  def run_generator
    stub_ask_responses
    stub_sub_generators

    Rails::Generators.invoke(
      "groundwork:form",
      ["AtfExplosivesLicense",
       "--fields", fixture_fields,
       "--journey", fixture_journey],
      destination_root: destination,
      behavior: :invoke
    )
  end

  it "prints steps and pages found in the manifest" do
    output = capture_stdout { run_generator }
    expect(output).to include("Found 2 steps in journey: start, review-submit")
    expect(output).to include("Found 2 pages in form")
  end

  describe "flow generation" do
    it "creates a Flow class file" do
      run_generator
      flow_path = File.join(destination, "app/flows/atf_explosives_license_flow.rb")
      expect(File.exist?(flow_path)).to be(true)
    end

    it "includes Groundwork::Forms::Flow" do
      run_generator
      content = File.read(File.join(destination, "app/flows/atf_explosives_license_flow.rb"))
      expect(content).to include("include Groundwork::Forms::Flow")
    end

    it "has a task block named after the form" do
      run_generator
      content = File.read(File.join(destination, "app/flows/atf_explosives_license_flow.rb"))
      expect(content).to include("task :atf_explosives_license do")
    end

    it "generates a question_page for the 'start' step" do
      run_generator
      content = File.read(File.join(destination, "app/flows/atf_explosives_license_flow.rb"))
      expect(content).to include("question_page :start,")
    end

    it "generates a question_page with empty fields for the review step" do
      run_generator
      content = File.read(File.join(destination, "app/flows/atf_explosives_license_flow.rb"))
      expect(content).to include("question_page :review_submit, fields: []")
    end
  end

  it "delegates model/migration generation to groundwork:application_form" do
    stub_ask_responses
    generated_args = []
    allow(Rails::Generators).to receive(:invoke).and_wrap_original do |original, name, *rest|
      if name.to_s == "groundwork:application_form"
        generated_args.concat(Array(rest.first))
        nil
      else
        original.call(name, *rest)
      end
    end

    Rails::Generators.invoke(
      "groundwork:form",
      ["AtfExplosivesLicense",
       "--fields", fixture_fields,
       "--journey", fixture_journey],
      destination_root: destination,
      behavior: :invoke
    )

    expect(generated_args.first).to include("AtfExplosivesLicenseForm")
  end
end

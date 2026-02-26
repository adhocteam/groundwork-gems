# frozen_string_literal: true

module Groundwork
  # Base class for all intake application forms.
  #
  # Subclasses add program-specific fields using gov_attribute and standard
  # ActiveRecord attributes. The form is mutable while in :draft status and
  # becomes permanently immutable once submitted — the submitted record is the
  # legal record of what the applicant provided.
  #
  # @example
  #   class PermitApplicationForm < Groundwork::ApplicationForm
  #     gov_attribute :applicant_name,   :name
  #     gov_attribute :business_address, :address
  #     gov_attribute :business_ein,     :ein
  #
  #     validates :license_type, presence: true, on: :submit
  #   end
  #
  class ApplicationForm < ApplicationRecord
    self.abstract_class = true

    include GovernmentAttributes::Attributes

    define_model_callbacks :submit, only: %i[before after]

    attribute :user_id,      :string   # Login.gov subject identifier
    attribute :submitted_at, :datetime

    enum :status, { draft: 0, submitted: 1 }, prefix: false
    protected attr_writer :status

    before_update :prevent_modification_if_submitted, if: :was_submitted?
    after_commit  :publish_submitted_event,            if: :submitted?, on: %i[create update]

    # Validates with the :submit context, then marks the form as submitted.
    # Returns false (and adds errors) if validation fails.
    #
    # @return [Boolean]
    def submit!
      return false unless valid?(:submit)

      run_callbacks(:submit) do
        self[:status]       = :submitted
        self[:submitted_at] = Time.current
        save!
        true
      end
    end

    # Column list used by the migration generator to ensure base columns are present.
    def self.base_columns_for_migration
      %w[user_id:string status:integer submitted_at:datetime]
    end

    protected

    def event_payload
      { application_form_id: id, submitted_at: submitted_at }
    end

    private

    def was_submitted?
      status_before_last_save == "submitted" || status_previously_was == "submitted"
    end

    def prevent_modification_if_submitted
      errors.add(:base, "cannot be modified after submission")
      throw :abort
    end

    def publish_submitted_event
      return unless saved_change_to_status?(to: "submitted")

      CaseManagement::EventBus.publish("#{self.class.name}Submitted", event_payload)
    end
  end
end

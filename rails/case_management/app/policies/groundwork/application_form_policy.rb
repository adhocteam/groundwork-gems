# frozen_string_literal: true

module Groundwork
  class ApplicationFormPolicy < ApplicationPolicy
    # Any authenticated user can start a new application.
    def new?     = create?
    def create?
      user.present?
    end

    # Applicants can only view their own forms.
    def show?
      owns_record?
    end

    # Applicants can only edit their own draft forms.
    def update?
      owns_record? && record.draft?
    end

    # Applicants can only submit their own draft forms.
    def submit?
      owns_record? && record.draft?
    end

    def destroy?
      false
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        scope.where(user_id: user.id)
      end
    end

    private

    def owns_record?
      record.user_id == user.id
    end
  end
end

# frozen_string_literal: true

module Groundwork
  class CasePolicy < ApplicationPolicy
    # Only staff can view cases.
    def show?
      staff?
    end

    def update?
      staff?
    end

    class Scope < ApplicationPolicy::Scope
      def resolve
        staff? ? scope.all : scope.none
      end
    end

    private

    def staff?
      user.respond_to?(:staff?) ? user.staff? : false
    end
  end
end

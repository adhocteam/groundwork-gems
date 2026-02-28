# Authorization

This engine uses Pundit and provides base policies in `app/policies`.

After reading this guide, you will know:

- What the base policies permit
- What your host app is expected to provide on `user`
- How to extend policies for app-specific rules

## Base policies

### `Groundwork::ApplicationFormPolicy`

Assumptions:

- `record.user_id` stores the authenticated user identifier
- `user.id` matches that identifier

Rules:

- Any authenticated user can `create?`
- A user can `show?`, `update?`, and `submit?` *only* for their own record
- Updates/submits are limited to draft forms

### `Groundwork::CasePolicy`

Assumptions:

- A “staff” user responds to `staff?`

Rules:

- Only staff can `show?` and `update?`
- The scope returns all for staff, none otherwise

## Host app policies

Most host apps will create program-specific policies that inherit from these base policies and add additional rules:

```ruby
class PermitApplicationFormPolicy < Groundwork::ApplicationFormPolicy
  # add program-specific rules here
end
```

If your authentication model differs (e.g. users don’t use `id` as the subject identifier, or staff is a role column), override the helper methods in your base policy subclasses.


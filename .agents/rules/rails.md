---
description: Rails rules
globs:
alwaysApply: true
---

# Rails Version
This application uses Rails 8.1

# Environment Setup
- Always ensure the correct Ruby environment is loaded before running any Ruby/Rails command:
  ```bash
    rvm use $(cat .ruby-version)@$(cat .ruby-gemset)
  ```

# Generators

* ALWAYS use Rails generators instead of manually creating files:

  * `rails g model`
  * `rails g controller`
  * `rails g migration`
  * `rails g resource`

# Migrations

* NEVER modify existing migration files once committed or shared.
* Create a new migration for any schema change.

# Code Practices

* Follow RESTful conventions for controllers.
* Keep controllers thin and move business logic to models or services.
* Prefer service objects for complex workflows.

# ActiveRecord

* Avoid N+1 queries (use `includes`, `preload`).
* Use scopes for reusable queries.
* Avoid loading unnecessary columns.

# Safety Rules (STRICT)

* Do NOT:

  * Run destructive DB commands (`db:drop`, `db:reset`) unless explicitly requested.
  * Modify production data logic without confirmation.

# Review Behavior

When editing code:

1. Prefer minimal, safe changes.
2. Maintain backward compatibility.
3. Highlight risks before applying changes.

# Output Expectations

* Provide explanation before major changes.
* Suggest improvements, not just fixes.

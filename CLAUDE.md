# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Mandatory Requirements

The codebase **shall** pass RuboCop without offenses (`bin/rubocop`).
The test suite **shall** pass all RSpec specs (`bundle exec rspec`).

## Local Development Setup

- **Ruby:** 3.4.4 (`.ruby-version`).
- **Database:** PostgreSQL. Dev/test DBs: `task_tracker_development` / `task_tracker_test`. See `config/database.yml`.

## Architecture

### Tech Stack

- **Ruby** 3.4.4, **Rails** 8.1 — **API-only** (`config.api_only = true`; no views, assets, or frontend).
- **PostgreSQL** (`pg`), **Puma**.
- **Alba** — JSON serializers.
- **dry-validation** — input validation (see [Validation](#validation)).
- **Testing:** RSpec (`rspec-rails`), FactoryBot.
- **rspec-openapi** — OpenAPI schema generation (see [API Schema Management](#api-schema-management)).

### Project Structure

```
app/
├── controllers/   # API controllers (+ concerns/)
├── contracts/     # dry-validation contracts — request validation
├── services/      # service objects — business logic
├── models/        # ActiveRecord models (+ concerns/)
├── serializers/   # Alba serializers — JSON output
└── jobs/          # Active Job jobs
config/            # Rails config — routes.rb, database.yml, environments/, initializers/
db/                # schema files, migrations, seeds.rb
spec/
├── requests/      # request specs
└── factories/     # FactoryBot factories
docs/              # project documentation
```

### Validation

Request input flows through **strong parameters → dry-validation contract**:
`params.permit`/`require` shapes the input (mass-assignment safety), then a contract
in `app/contracts/` validates it (required fields, types, ranges, business rules)
before any domain code runs. The contract produces the `422` error details; DB
`CHECK` constraints stay as the last line of defense.

## Domain

<!-- short description of the domain (recurring task tracker) — fill in as it's built. -->

## Code Style

- **No comments in code.** Do not write explanatory comments. Code must be self-explanatory through naming and structure. The only permitted comment is the `# frozen_string_literal: true` magic comment.

## RSpec Conventions

- **No monkey-patching model instances.** Do not use `define_singleton_method` or `instance_variable_set` to add behavior to model instances. If a model needs a virtual attribute, add `attr_accessor` to the model class.
- **Use `match_array` in RSpec.** When comparing array contents, use `match_array(expected)` instead of `include(*expected)`. `match_array` verifies exact contents; `include` only checks partial inclusion.
- **No `super()` in `let` overrides.** Do not call `super()` inside RSpec `let` blocks to extend parent definitions. Instead, define a `let(:base_*)` with the default value and use `base_*.merge(...)` in nested contexts.
- **Full-cycle specs for data pipelines.** Any pipeline that processes input end-to-end (e.g., request → service → persisted records) must have a spec covering the complete flow, verifying all fields and associations are saved correctly. Per-service unit specs alone are not sufficient.

## API Schema Management

> **Never run autonomously — only on the user's explicit request.** Do not run
> OpenAPI generation or write/modify request specs on your own initiative. Wait
> until the user explicitly asks.

<!-- how it works (rspec-openapi, paths, regeneration) — fill in later. -->

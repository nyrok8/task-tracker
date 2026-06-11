# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Mandatory Requirements

The codebase **shall** pass RuboCop without offenses (`bin/rubocop`).
The test suite **shall** pass all RSpec specs (`bundle exec rspec`).

## Local Development Setup

- **Ruby:** 3.4.4 (`.ruby-version`).
- **Database:** PostgreSQL. Dev/test DBs: `task_tracker_development` / `task_tracker_test`. See `config/database.yml`.
- **Bootstrap:** `bundle install && bin/rails db:create db:migrate db:seed` (seeds create the system tags).
- **Time zone:** `Europe/Moscow` (`config.time_zone`). Date↔time conversions go through `Time.zone` /
  `in_time_zone` — never `Date#to_time` (it uses the system TZ).

## Architecture

### Tech Stack

- **Ruby** 3.4.4, **Rails** 8.1 — **API-only** (`config.api_only = true`; no views, assets, or frontend).
- **PostgreSQL** (`pg`), **Puma**.
- **dry-validation** — input validation (see [Validation](#validation)).
- **Ransack** — list filtering behind an explicit param map (see [Filtering](#filtering)).
- **ice_cube** — recurrence expansion inside `DatesCalculator`.
- **Testing:** RSpec (`rspec-rails`), FactoryBot.
- **rspec-openapi** — OpenAPI docs generation (see [API Schema Management](#api-schema-management)).

### Project Structure

```
app/
├── controllers/   # API controllers (+ concerns/) — thin: params → contract/service → render
├── contracts/     # dry-validation contracts — request validation
├── services/      # service objects — business logic (list services, CreateService)
├── models/        # ActiveRecord models (+ concerns/) — Tasks namespace module lives here
└── lib/           # domain machinery — DatesCalculator, OccurrenceQuery, SearchFilters
config/            # Rails config — routes.rb, database.yml, environments/, initializers/
db/                # schema, migrations, seeds.rb (system tags)
spec/
├── contracts/     # contract specs
├── controllers/   # controller specs (custom controller logic only)
├── lib/           # specs for app/lib
├── services/      # service specs
├── requests/      # OpenAPI-generating specs — NOT behavior tests (see API Schema Management)
├── factories/     # FactoryBot factories
└── support/       # openapi_config.rb
swagger/           # generated OpenAPI docs (one yaml per API area)
```

### Validation

Request input flows through **strong parameters → dry-validation contract**:
`params.expect` shapes the input (mass-assignment safety), then a contract
in `app/contracts/` validates it (required fields, types, ranges, business rules)
before any domain code runs. The contract produces the `422` error details; DB
`CHECK` constraints stay as the last line of defense.

## Domain

API for the **task tracker** module of a medical information system (MIS): staff
(doctors, admins) create work tasks — operations, patient rounds, calls, reports.

Tasks come in **two types, modeled as two separate write-domains** under the
`Tasks::` namespace, with a **single unified read view**:

- **One-off** (`Tasks::OneOff`, table `tasks_one_offs`) — a single task with a
  concrete `scheduled_at` and its own `status`.
- **Recurring** (`Tasks::Recurring::*`) — a **create-only `Template`** (immutable
  blueprint: name/description/scheduled_at/status/assignee) plus a **1:1 `Rule`**
  holding the recurrence parameters. Once created, a template is never edited;
  per-instance changes go through `Override`.

### `scheduled_at` vs `date_key`

The two date-like fields of an occurrence carry **different responsibilities**:

- **`scheduled_at`** — the **business datetime**: when the task is actually due.
  It is the single business axis — listing windows, datetime filtering, and sorting
  all work on `scheduled_at` (for one-offs and occurrences alike).
- **`date_key`** — the occurrence's **natural identifier** (a stored auto-id would
  be meaningless for rows that are never stored). It addresses an occurrence in
  URLs (`/overrides/:date_key`) and keys overrides. It is **never used in business
  logic** — moving an occurrence changes `scheduled_at`, never `date_key`.

An occurrence's default `scheduled_at` = its `date_key` + the template's
time-of-day; an override may move it to any datetime (same day, another day —
the `date_key` stays put, so the instance remains addressable after the move).

### Occurrences are computed, never materialized

A recurring task's individual dated instances ("occurrences") are **not stored** —
persisting millions of rows for an open-ended rule is the thing to avoid. Instead
occurrences are expanded on the fly for a requested period by
`Tasks::Recurring::OccurrenceQuery`:

1. `DatesCalculator` expands the `Rule` into occurrence dates for the period.
2. Overrides **moved into the period** by `scheduled_at` are unioned in — so an
   instance moved across a week boundary is found in its new week, not its old one.
3. One SQL overlay (`Template ⊕ Override` via `COALESCE`, jsonb recordset join)
   builds the merged rows; tombstoned dates are skipped; the final cut is
   `WHERE scheduled_at IN period`.

The result is exposed as `Tasks::Recurring::Occurrence` — a **read-only AR
projection** (no table of its own; it borrows the overrides schema for column
metadata and Ransack). `OccurrenceQuery#call` returns a real
`ActiveRecord::Relation`, so Ransack/`where`/`order` compose on top.

### Override = sparse per-occurrence delta

A `Tasks::Recurring::Override` row, keyed uniquely by `(template_id, date_key)`,
stores **only the fields that deviate** from the template; a `NULL` column means
"inherit from the template". It carries three independent things:

- **Independent per-instance state** — marking just June 9 as `done` or `cancelled`
  writes `status` on that date's override, leaving every other date untouched.
- **Per-instance move** — an override's `scheduled_at` relocates that single
  instance in time (hours or days); the rule and all other instances stay put.
- **`deleted_at` tombstone** — the `destroy` of a single occurrence. A virtual
  occurrence can't be row-deleted (the rule would re-emit the date), so the
  tombstone tells expansion to **skip that date**.

Cancel (`status: 'cancelled'`, still listed) ≠ destroy (`deleted_at`, gone from list).

### Recurrence types (`Rule.recurrence_type`)

| type | meaning | key fields |
| --- | --- | --- |
| `daily` | every n-th day | `day_interval` |
| `monthly_day` | a fixed day of the month (1–31, clamped to month length) | `month_day` |
| `month_parity` | even / odd days of the month | `parity` |
| `specific_dates` | only the listed dates | `dates[]` |

Anchored by `starts_on`; bounded by `ends_on` **or** `max_count` (open-ended when
both are null — never both at once). DB `CHECK` constraints enforce which fields are
valid per type. `CreateService` keeps only the params relevant to the chosen type.

### Filtering

List filtering is Ransack behind an **explicit translation map** — clients never
send raw Ransack predicates:

- `Tasks::SearchFilters` (mixin) holds the shared `FILTERS` map
  (`status`, `statuses`, `assignee_id`, `query`, `tag`); each list
  service includes it and may extend `FILTERS` (occurrences add `template_id`).
- `Tasks::Filterable` (model concern) holds the Ransack whitelists and the
  `ransack_tagged_with` scope (`text[]` containment) for `OneOff` and `Occurrence`.
- The period (`from`/`to` datetimes) bounds the selection by `scheduled_at`;
  it is not a filter param. Its length is capped (`TasksController::MAX_PERIOD`,
  366 days) — an oversized or malformed request gets a `400`.

### Reads & tags

- **`GET /tasks`** is the only cross-domain endpoint: `Tasks::ListService` merges
  filtered one-offs with expanded occurrences for the period into one list sorted
  by `scheduled_at`. Each item carries `kind` (`one_off` / `occurrence`) plus its
  identity (`id` vs `template_id` + `date_key`). Each domain keeps its own `show`.
- **Tags** — an array of tag names on each task, validated against the `Tag`
  registry. The system tags «отчетность», «операции», «звонок» are seeded with
  `system: true` and are protected from edit and delete.

## Code Style

- **No comments in code.** Do not write explanatory comments. Code must be self-explanatory through naming and structure. The only permitted comment is the `# frozen_string_literal: true` magic comment.
- **Constants over AR enums.** Allowed values use the compact idiom
  `STATUSES = [PENDING = 'pending', ...].freeze` — on the model when they belong to
  one entity, on the `Tasks` namespace (`app/models/tasks.rb`) when shared.

## RSpec Conventions

- **One top-level `describe` per spec; every `context` has its own `it`.** No empty
  grouping contexts. Prefer a named `subject` over helper methods.
- **No monkey-patching model instances.** Do not use `define_singleton_method` or `instance_variable_set` to add behavior to model instances. If a model needs a virtual attribute, add `attr_accessor` to the model class.
- **Use `match_array` in RSpec.** When comparing array contents, use `match_array(expected)` instead of `include(*expected)`. `match_array` verifies exact contents; `include` only checks partial inclusion.
- **No `super()` in `let` overrides.** Do not call `super()` inside RSpec `let` blocks to extend parent definitions. Instead, define a `let(:base_*)` with the default value and use `base_*.merge(...)` in nested contexts.
- **Full-cycle specs for data pipelines.** Any pipeline that processes input end-to-end (e.g., request → service → persisted records) must have a spec covering the complete flow, verifying all fields and associations are saved correctly. Per-service unit specs alone are not sufficient.
- **While developing, run only the spec you are working on.** The full suite is a
  final verification step, not a per-edit loop.

## API Schema Management

> **Never regenerate autonomously — only on the user's explicit request.** Do not
> run OpenAPI generation or write/modify `spec/requests` on your own initiative.

`spec/requests` are **not behavior tests** — they exist to drive `rspec-openapi`
documentation generation (one spec file per endpoint action, asserting statuses).
`spec/support/openapi_config.rb` maps spec paths to output files — one yaml per
API area in `swagger/` (`tasks`, `one_offs`, `recurring`, `tags`, `users`).

Regenerate with: `OPENAPI=1 bundle exec rspec spec/requests`

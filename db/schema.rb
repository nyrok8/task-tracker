# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_06_09_120007) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "day_parity", ["even", "odd"]
  create_enum "recurrence_type", ["daily", "monthly_day", "specific_dates", "month_parity"]
  create_enum "task_status", ["pending", "done", "cancelled"]

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.string "name", null: false
    t.boolean "system", default: false, null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "tasks_one_offs", force: :cascade do |t|
    t.bigint "assignee_id"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.text "description", null: false
    t.string "name", null: false
    t.datetime "scheduled_at", null: false
    t.enum "status", default: "pending", null: false, enum_type: "task_status"
    t.string "tags", default: [], null: false, array: true
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["assignee_id"], name: "index_tasks_one_offs_on_assignee_id"
    t.index ["scheduled_at"], name: "index_tasks_one_offs_on_scheduled_at"
    t.index ["tags"], name: "index_tasks_one_offs_on_tags", using: :gin
  end

  create_table "tasks_recurring_overrides", force: :cascade do |t|
    t.bigint "assignee_id"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.date "date_key", null: false
    t.datetime "deleted_at"
    t.text "description"
    t.string "name"
    t.datetime "scheduled_at"
    t.enum "status", enum_type: "task_status"
    t.string "tags", array: true
    t.bigint "template_id", null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["assignee_id"], name: "index_tasks_recurring_overrides_on_assignee_id"
    t.index ["tags"], name: "index_tasks_recurring_overrides_on_tags", using: :gin
    t.index ["template_id", "date_key"], name: "index_recurring_overrides_on_template_and_date_key", unique: true
    t.index ["template_id", "scheduled_at"], name: "index_recurring_overrides_on_template_and_scheduled"
  end

  create_table "tasks_recurring_rules", force: :cascade do |t|
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.date "dates", array: true
    t.integer "day_interval", default: 1, null: false
    t.date "ends_on"
    t.integer "max_count"
    t.integer "month_day"
    t.enum "parity", enum_type: "day_parity"
    t.enum "recurrence_type", null: false, enum_type: "recurrence_type"
    t.date "starts_on", null: false
    t.bigint "template_id", null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["template_id"], name: "uniq_recurring_rule_per_template", unique: true
    t.check_constraint "NOT (ends_on IS NOT NULL AND max_count IS NOT NULL)", name: "chk_end_xor_count"
    t.check_constraint "\nCASE recurrence_type\n    WHEN 'daily'::recurrence_type THEN month_day IS NULL AND parity IS NULL AND dates IS NULL\n    WHEN 'monthly_day'::recurrence_type THEN month_day IS NOT NULL AND parity IS NULL AND dates IS NULL\n    WHEN 'month_parity'::recurrence_type THEN parity IS NOT NULL AND month_day IS NULL AND dates IS NULL\n    WHEN 'specific_dates'::recurrence_type THEN dates IS NOT NULL AND cardinality(dates) > 0 AND array_position(dates, NULL::date) IS NULL AND month_day IS NULL AND parity IS NULL\n    ELSE NULL::boolean\nEND", name: "chk_fields_by_type"
    t.check_constraint "day_interval > 0", name: "chk_day_interval_positive"
    t.check_constraint "ends_on IS NULL OR ends_on >= starts_on", name: "chk_window_order"
    t.check_constraint "max_count IS NULL OR max_count > 0", name: "chk_max_count_positive"
    t.check_constraint "month_day IS NULL OR month_day >= 1 AND month_day <= 31", name: "chk_month_day_range"
  end

  create_table "tasks_recurring_templates", force: :cascade do |t|
    t.bigint "assignee_id"
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.text "description", null: false
    t.string "name", null: false
    t.datetime "scheduled_at", null: false
    t.enum "status", default: "pending", null: false, enum_type: "task_status"
    t.string "tags", default: [], null: false, array: true
    t.datetime "updated_at", default: -> { "now()" }, null: false
    t.index ["assignee_id"], name: "index_tasks_recurring_templates_on_assignee_id"
    t.index ["tags"], name: "index_tasks_recurring_templates_on_tags", using: :gin
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", default: -> { "now()" }, null: false
    t.string "name", null: false
    t.datetime "updated_at", default: -> { "now()" }, null: false
  end

  add_foreign_key "tasks_one_offs", "users", column: "assignee_id", on_delete: :nullify
  add_foreign_key "tasks_recurring_overrides", "tasks_recurring_templates", column: "template_id", on_delete: :cascade
  add_foreign_key "tasks_recurring_overrides", "users", column: "assignee_id", on_delete: :nullify
  add_foreign_key "tasks_recurring_rules", "tasks_recurring_templates", column: "template_id", on_delete: :cascade
  add_foreign_key "tasks_recurring_templates", "users", column: "assignee_id", on_delete: :nullify
end

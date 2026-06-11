# frozen_string_literal: true

class CreateTasksRecurringRules < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks_recurring_rules do |t|
      t.references :template, null: false,
        foreign_key: { to_table: :tasks_recurring_templates, on_delete: :cascade },
        index: { unique: true, name: 'uniq_recurring_rule_per_template' }
      t.enum :recurrence_type, enum_type: :recurrence_type, null: false
      t.date :starts_on, null: false
      t.date :ends_on
      t.integer :day_interval, null: false, default: 1
      t.integer :month_day
      t.enum :parity, enum_type: :day_parity
      t.date :dates, array: true
      t.integer :max_count
      t.timestamps default: -> { 'now()' }

      t.check_constraint 'day_interval > 0', name: 'chk_day_interval_positive'
      t.check_constraint 'month_day IS NULL OR month_day BETWEEN 1 AND 31', name: 'chk_month_day_range'
      t.check_constraint 'max_count IS NULL OR max_count > 0', name: 'chk_max_count_positive'
      t.check_constraint 'ends_on IS NULL OR ends_on >= starts_on', name: 'chk_window_order'
      t.check_constraint 'NOT (ends_on IS NOT NULL AND max_count IS NOT NULL)', name: 'chk_end_xor_count'
      t.check_constraint <<~SQL.squish, name: 'chk_fields_by_type'
        CASE recurrence_type
            WHEN 'daily' THEN month_day IS NULL AND parity IS NULL AND dates IS NULL
            WHEN 'monthly_day' THEN month_day IS NOT NULL AND parity IS NULL AND dates IS NULL
            WHEN 'month_parity' THEN parity IS NOT NULL AND month_day IS NULL AND dates IS NULL
            WHEN 'specific_dates' THEN dates IS NOT NULL AND cardinality(dates) > 0
                AND array_position(dates, NULL) IS NULL AND month_day IS NULL AND parity IS NULL
        END
      SQL
    end
  end
end

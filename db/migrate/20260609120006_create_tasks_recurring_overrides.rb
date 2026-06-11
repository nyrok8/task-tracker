# frozen_string_literal: true

class CreateTasksRecurringOverrides < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks_recurring_overrides do |t|
      t.references :template, null: false,
        foreign_key: { to_table: :tasks_recurring_templates, on_delete: :cascade }, index: false
      t.date :date_key, null: false
      t.datetime :scheduled_at
      t.enum :status, enum_type: :task_status
      t.string :name
      t.text :description
      t.references :assignee, foreign_key: { to_table: :users, on_delete: :nullify }
      t.string :tags, array: true
      t.datetime :deleted_at
      t.timestamps default: -> { 'now()' }
    end
    add_index :tasks_recurring_overrides, %i[template_id date_key], unique: true,
      name: 'index_recurring_overrides_on_template_and_date_key'
    add_index :tasks_recurring_overrides, %i[template_id scheduled_at],
      name: 'index_recurring_overrides_on_template_and_scheduled'
    add_index :tasks_recurring_overrides, :tags, using: :gin
  end
end

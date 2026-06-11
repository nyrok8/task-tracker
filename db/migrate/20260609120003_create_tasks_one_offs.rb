# frozen_string_literal: true

class CreateTasksOneOffs < ActiveRecord::Migration[8.1]
  def change
    create_table :tasks_one_offs do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.datetime :scheduled_at, null: false
      t.enum :status, enum_type: :task_status, null: false, default: 'pending'
      t.references :assignee, foreign_key: { to_table: :users, on_delete: :nullify }
      t.string :tags, array: true, null: false, default: []
      t.timestamps default: -> { 'now()' }
    end
    add_index :tasks_one_offs, :scheduled_at
    add_index :tasks_one_offs, :tags, using: :gin
  end
end

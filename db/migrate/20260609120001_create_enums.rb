# frozen_string_literal: true

class CreateEnums < ActiveRecord::Migration[8.1]
  def up
    create_enum :task_status, %w[pending done cancelled]
    create_enum :recurrence_type, %w[daily monthly_day specific_dates month_parity]
    create_enum :day_parity, %w[even odd]
  end

  def down
    drop_enum :day_parity
    drop_enum :recurrence_type
    drop_enum :task_status
  end
end

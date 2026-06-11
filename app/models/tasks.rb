# frozen_string_literal: true

module Tasks
  STATUSES = [
    PENDING = 'pending',
    DONE = 'done',
    CANCELLED = 'cancelled'
  ].freeze

  ATTRIBUTES = %i[name description scheduled_at status assignee_id tags].freeze

  def self.table_name_prefix
    'tasks_'
  end
end

# frozen_string_literal: true

class TaskContract < Dry::Validation::Contract
  option :record

  json do
    optional(:name).maybe(:string, max_size?: 64)
    optional(:description).maybe(:string, max_size?: 255)
    optional(:scheduled_at).maybe(:time)
    optional(:status).maybe(:string, included_in?: Tasks::STATUSES)
    optional(:assignee_id).maybe(:integer)
    optional(:tags).maybe(:array)
  end

  %i[name description scheduled_at].each do |field|
    rule(field) do
      next if record.is_a?(Tasks::Recurring::Override)

      key.failure('must be filled') if value.blank?
    end
  end

  rule(:assignee_id) do
    next unless value

    key.failure('does not exist') unless User.exists?(value)
  end

  rule(:tags) do
    next if value.blank?

    unknown_tags = value - Tag.names
    key.failure("unknown tags: #{unknown_tags.join(', ')}") if unknown_tags.any?
  end
end

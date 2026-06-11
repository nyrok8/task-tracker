# frozen_string_literal: true

class RecurringRuleContract < Dry::Validation::Contract
  Rule = Tasks::Recurring::Rule

  json do
    optional(:recurrence_type).maybe(:string, included_in?: Rule::RECURRENCE_TYPES)
    optional(:starts_on).maybe(:date)
    optional(:ends_on).maybe(:date)
    optional(:max_count).maybe(:integer, gt?: 0)
    optional(:day_interval).maybe(:integer, gt?: 0)
    optional(:month_day).maybe(:integer, gteq?: 1, lteq?: 31)
    optional(:parity).maybe(:string, included_in?: Rule::PARITIES)
    optional(:dates).maybe(:array)
  end

  rule(:recurrence_type) do
    key.failure('must be filled') if value.blank?
  end

  rule(:starts_on) do
    key.failure('must be filled') if value.blank?
  end

  rule(:ends_on) do
    next if value.blank? || values[:starts_on].blank?

    key.failure('must be on or after starts_on') if value < values[:starts_on]
  end

  rule(:max_count) do
    key.failure('cant be set together with ends_on') if value.present? && values[:ends_on].present?
  end

  rule(:month_day) do
    next unless values[:recurrence_type] == Rule::MONTHLY_DAY

    key.failure('must be filled') if value.blank?
  end

  rule(:parity) do
    next unless values[:recurrence_type] == Rule::MONTH_PARITY

    key.failure('must be filled') if value.blank?
  end

  rule(:dates) do
    next unless values[:recurrence_type] == Rule::SPECIFIC_DATES

    key.failure('must be filled') if value.blank?
  end

  rule(:dates) do
    next unless values[:recurrence_type] == Rule::SPECIFIC_DATES

    key.failure('cant contain blank dates') if value&.any?(&:blank?)
  end
end

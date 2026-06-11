# frozen_string_literal: true

FactoryBot.define do
  factory :recurring_rule, class: 'Tasks::Recurring::Rule' do
    template factory: :recurring_template
    starts_on { Date.new(2024, 1, 1) }
    recurrence_type { Tasks::Recurring::Rule::DAILY }
    day_interval { 1 }

    trait :daily do
      recurrence_type { Tasks::Recurring::Rule::DAILY }
    end

    trait :monthly_day do
      recurrence_type { Tasks::Recurring::Rule::MONTHLY_DAY }
      month_day { 31 }
    end

    trait :month_parity do
      recurrence_type { Tasks::Recurring::Rule::MONTH_PARITY }
      parity { 'even' }
    end

    trait :specific_dates do
      recurrence_type { Tasks::Recurring::Rule::SPECIFIC_DATES }
      dates { [Date.new(2024, 1, 15), Date.new(2024, 2, 20)] }
    end
  end
end

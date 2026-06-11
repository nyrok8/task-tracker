# frozen_string_literal: true

FactoryBot.define do
  factory :recurring_override, class: 'Tasks::Recurring::Override' do
    template factory: :recurring_template
    date_key { Date.current }
  end
end

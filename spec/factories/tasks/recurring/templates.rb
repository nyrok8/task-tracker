# frozen_string_literal: true

FactoryBot.define do
  factory :recurring_template, class: 'Tasks::Recurring::Template' do
    name { 'Daily rounds' }
    description { 'Daily patient rounds' }
    scheduled_at { 1.day.from_now }
  end
end

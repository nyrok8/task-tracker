# frozen_string_literal: true

FactoryBot.define do
  factory :one_off, class: 'Tasks::OneOff' do
    name { 'Patient round' }
    description { 'Morning ward round' }
    scheduled_at { 1.day.from_now }
  end
end

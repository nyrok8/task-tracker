# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tasks::Recurring::CreateService do
  subject(:result) { described_class.new(template_params:, rule_params:).call }

  let(:template_params) do
    { name: 'Daily rounds', description: 'Daily patient rounds', scheduled_at: Time.zone.local(2026, 6, 1, 10) }
  end
  let(:rule_params) { { recurrence_type: 'daily', starts_on: Date.new(2026, 6, 1), day_interval: 2 } }

  it 'persists the template with its rule' do
    expect { result }.to change { Tasks::Recurring::Template.count }.by(1)
      .and change { Tasks::Recurring::Rule.count }.by(1)
  end

  it 'saves every template and rule field' do
    template = result.template.reload
    expect(result).to be_success
    expect(template.slice(:name, :description, :scheduled_at).symbolize_keys).to eq(template_params)
    expect(template.rule.slice(:recurrence_type, :starts_on, :day_interval).symbolize_keys).to eq(rule_params)
  end

  context 'with fields from another recurrence type' do
    let(:rule_params) do
      { recurrence_type: 'daily', starts_on: Date.new(2026, 6, 1), day_interval: 2, month_day: 15, parity: 'even' }
    end

    it 'discards the irrelevant fields' do
      rule = result.template.rule
      expect([rule.day_interval, rule.month_day, rule.parity]).to eq([2, nil, nil])
    end
  end

  context 'when the template is invalid' do
    let(:template_params) { { description: 'Daily patient rounds', scheduled_at: Time.zone.local(2026, 6, 1, 10) } }

    it 'returns errors and persists nothing' do
      expect { result }.not_to change { Tasks::Recurring::Template.count }
      expect(result).not_to be_success
      expect(result.errors).to have_key(:name)
    end
  end

  context 'when the rule is invalid' do
    let(:rule_params) { { recurrence_type: 'daily', day_interval: 2 } }

    it 'returns errors and persists nothing' do
      expect { result }.not_to change { Tasks::Recurring::Rule.count }
      expect(result).not_to be_success
      expect(result.errors).to have_key(:starts_on)
    end
  end
end

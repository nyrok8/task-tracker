# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tasks::ListService do
  subject(:result) { described_class.new(period, search_params).call }

  let(:period) { Time.zone.local(2026, 6, 9)..Time.zone.local(2026, 6, 10, 23, 59, 59) }
  let(:search_params) { {} }
  let(:template) { create(:recurring_template, name: 'Rounds', scheduled_at: Time.zone.local(2026, 6, 1, 10)) }
  let(:one_off) { create(:one_off, name: 'Call', scheduled_at: Time.zone.local(2026, 6, 9, 8)) }

  let(:expected_result) do
    [
      {
        name: 'Call',
        description: 'Morning ward round',
        scheduled_at: Time.zone.local(2026, 6, 9, 8),
        status: 'pending',
        assignee_id: nil,
        tags: [],
        kind: 'one_off',
        id: one_off.id
      },
      {
        name: 'Rounds',
        description: 'Daily patient rounds',
        scheduled_at: Time.zone.local(2026, 6, 9, 10),
        status: 'pending',
        assignee_id: nil,
        tags: [],
        kind: 'occurrence',
        template_id: template.id,
        date_key: Date.new(2026, 6, 9)
      },
      {
        name: 'Rounds',
        description: 'Daily patient rounds',
        scheduled_at: Time.zone.local(2026, 6, 10, 10),
        status: 'pending',
        assignee_id: nil,
        tags: [],
        kind: 'occurrence',
        template_id: template.id,
        date_key: Date.new(2026, 6, 10)
      }
    ]
  end

  before do
    create(:recurring_rule, :daily, template:, starts_on: Date.new(2026, 6, 1))
    one_off
  end

  it 'merges one-offs with occurrences into a unified list sorted by scheduled_at' do
    expect(result).to eq(expected_result)
  end

  context 'when filtering' do
    let(:search_params) { { status: 'done' } }

    before do
      create(:one_off, name: 'Done call', scheduled_at: Time.zone.local(2026, 6, 9, 14), status: 'done')
      create(:recurring_override, template:, date_key: Date.new(2026, 6, 10), status: 'done')
    end

    it 'applies the filter to both domains' do
      expect(result.map { |task| task.values_at(:kind, :name) })
        .to contain_exactly(['one_off', 'Done call'], ['occurrence', 'Rounds'])
    end
  end

  context 'when filtering by template' do
    let(:search_params) { { template_id: template.id } }

    it 'returns only occurrences of that template' do
      expect(result.pluck(:kind)).to match_array(%w[occurrence occurrence])
    end
  end

  context 'when nothing falls in the period' do
    let(:period) { Time.zone.local(2025, 1, 1)..Time.zone.local(2025, 1, 2) }

    it 'is empty' do
      expect(result).to be_empty
    end
  end
end

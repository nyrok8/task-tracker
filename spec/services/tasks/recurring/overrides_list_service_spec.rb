# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tasks::Recurring::OverridesListService do
  subject(:result) { described_class.new([template, other_template], period, search_params).call }

  let(:period) { Time.zone.local(2026, 1, 1)..Time.zone.local(2026, 1, 5, 23, 59, 59) }
  let(:dates) { (Date.new(2026, 1, 1)..Date.new(2026, 1, 5)).to_a }
  let(:template) { create(:recurring_template, scheduled_at: Time.zone.local(2026, 1, 1, 9)) }
  let(:other_template) do
    create(:recurring_template, name: 'Phone calls', scheduled_at: Time.zone.local(2026, 1, 1, 9))
  end
  let(:assignee) { create(:user) }
  let(:search_params) { {} }

  before do
    create(:recurring_rule, :daily, template:, starts_on: Date.new(2026, 1, 1))
    create(:recurring_rule, :daily, template: other_template, starts_on: Date.new(2026, 1, 1))

    create(:recurring_override, template:, date_key: Date.new(2026, 1, 1), status: 'cancelled')
    create(:recurring_override, template:, date_key: Date.new(2026, 1, 3), assignee:, status: 'done')
    create(:recurring_override, template:, date_key: Date.new(2026, 1, 4), name: 'Surgery', description: 'Emergency')
    create(:recurring_override, template:, date_key: Date.new(2026, 1, 5), tags: ['urgent'])
  end

  context 'when filtering by status' do
    let(:search_params) { { status: 'cancelled' } }

    it 'returns only the cancelled occurrence' do
      expect(result.map(&:date_key)).to contain_exactly(Date.new(2026, 1, 1))
    end
  end

  context 'when filtering by statuses' do
    let(:search_params) { { statuses: %w[cancelled done] } }

    it 'returns occurrences with any of the listed statuses' do
      expect(result.map(&:date_key)).to contain_exactly(Date.new(2026, 1, 1), Date.new(2026, 1, 3))
    end
  end

  context 'when filtering by assignee' do
    let(:search_params) { { assignee_id: assignee.id } }

    it 'returns only the occurrence with that assignee' do
      expect(result.map(&:date_key)).to contain_exactly(Date.new(2026, 1, 3))
    end
  end

  context 'when searching by query' do
    let(:search_params) { { query: 'Surgery' } }

    it 'returns occurrences matching name or description' do
      expect(result.map(&:date_key)).to contain_exactly(Date.new(2026, 1, 4))
    end
  end

  context 'when filtering by tag' do
    let(:search_params) { { tag: 'urgent' } }

    it 'returns only occurrences carrying the tag' do
      expect(result.map(&:date_key)).to contain_exactly(Date.new(2026, 1, 5))
    end
  end

  context 'when filtering by template' do
    let(:search_params) { { template_id: template.id } }

    it 'returns only that template occurrences' do
      expect(result.map(&:date_key)).to match_array(dates)
    end
  end

  context 'without filters' do
    it 'returns every occurrence of both templates' do
      pairs = dates.flat_map { |date| [[template.id, date], [other_template.id, date]] }
      expect(result.map { |o| [o.template_id, o.date_key] }).to match_array(pairs)
    end
  end

  context 'with blank or unknown params' do
    let(:search_params) { { status: '', unknown: 'x' } }

    it 'ignores them and returns every occurrence' do
      expect(result.map(&:date_key)).to match_array(dates.flat_map { |date| [date, date] })
    end
  end

  context 'with filters that intersect to nothing' do
    let(:search_params) { { status: 'cancelled', tag: 'urgent' } }

    it 'returns no occurrences' do
      expect(result).to be_empty
    end
  end
end

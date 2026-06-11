# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tasks::OneOffsListService do
  subject(:result) { described_class.new(period, search_params).call }

  let(:period) { Time.zone.local(2026, 6, 1)..Time.zone.local(2026, 6, 30, 23, 59, 59) }
  let(:assignee) { create(:user) }
  let(:search_params) { {} }

  before do
    create(:one_off, name: 'Morning call', scheduled_at: Time.zone.local(2026, 6, 1, 8))
    create(:one_off, name: 'Surgery', description: 'Emergency', scheduled_at: Time.zone.local(2026, 6, 10, 12),
      status: 'done', assignee:, tags: ['urgent'])
    create(:one_off, name: 'Evening report', scheduled_at: Time.zone.local(2026, 6, 20, 18), status: 'cancelled')
    create(:one_off, name: 'Outside', scheduled_at: Time.zone.local(2026, 7, 5, 9))
  end

  context 'without filters' do
    it 'returns every one-off scheduled within the period' do
      expect(result.map(&:name)).to contain_exactly('Morning call', 'Surgery', 'Evening report')
    end
  end

  context 'when filtering by status' do
    let(:search_params) { { status: 'done' } }

    it 'returns only the done one-off' do
      expect(result.map(&:name)).to contain_exactly('Surgery')
    end
  end

  context 'when filtering by statuses' do
    let(:search_params) { { statuses: %w[done cancelled] } }

    it 'returns one-offs with any of the listed statuses' do
      expect(result.map(&:name)).to contain_exactly('Surgery', 'Evening report')
    end
  end

  context 'when filtering by assignee' do
    let(:search_params) { { assignee_id: assignee.id } }

    it 'returns only the one-off with that assignee' do
      expect(result.map(&:name)).to contain_exactly('Surgery')
    end
  end

  context 'when searching by query' do
    let(:search_params) { { query: 'Emergency' } }

    it 'returns one-offs matching name or description' do
      expect(result.map(&:name)).to contain_exactly('Surgery')
    end
  end

  context 'when filtering by tag' do
    let(:search_params) { { tag: 'urgent' } }

    it 'returns only one-offs carrying the tag' do
      expect(result.map(&:name)).to contain_exactly('Surgery')
    end
  end

  context 'when filtering by template' do
    let(:search_params) { { template_id: 1 } }

    it 'returns no one-offs' do
      expect(result).to be_empty
    end
  end

  context 'with blank or unknown params' do
    let(:search_params) { { status: '', unknown: 'x' } }

    it 'ignores them and returns every one-off in the period' do
      expect(result.map(&:name)).to contain_exactly('Morning call', 'Surgery', 'Evening report')
    end
  end
end

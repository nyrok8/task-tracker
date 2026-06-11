# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecurringRuleContract do
  subject(:result) { described_class.new.call(rule.attributes) }

  let(:rule) { build(:recurring_rule, :daily) }

  it 'validates required fields' do
    rule.assign_attributes(recurrence_type: nil, starts_on: nil)
    expect(result.errors[:recurrence_type]).to include('must be filled')
    expect(result.errors[:starts_on]).to include('must be filled')
  end

  it 'fails when recurrence_type is unknown' do
    rule.recurrence_type = 'weekly'
    expect(result).to be_failure
    expect(result.errors.to_h).to have_key(:recurrence_type)
  end

  it 'fails when ends_on is before starts_on' do
    rule.assign_attributes(starts_on: Date.new(2024, 1, 10), ends_on: Date.new(2024, 1, 1))
    expect(result).to be_failure
    expect(result.errors[:ends_on]).to include('must be on or after starts_on')
  end

  it 'fails when ends_on and max_count are both set' do
    rule.assign_attributes(ends_on: Date.new(2024, 1, 10), max_count: 3)
    expect(result).to be_failure
    expect(result.errors[:max_count]).to include('cant be set together with ends_on')
  end

  it 'fails when max_count is not positive' do
    rule.max_count = 0
    expect(result).to be_failure
    expect(result.errors.to_h).to have_key(:max_count)
  end

  context 'when daily' do
    it 'succeeds for a valid rule' do
      expect(result).to be_success
    end

    it 'fails when day_interval is not positive' do
      rule.day_interval = 0
      expect(result).to be_failure
      expect(result.errors.to_h).to have_key(:day_interval)
    end
  end

  context 'when monthly_day' do
    let(:rule) { build(:recurring_rule, :monthly_day) }

    it 'succeeds for a valid rule' do
      expect(result).to be_success
    end

    it 'requires month_day' do
      rule.month_day = nil
      expect(result.errors[:month_day]).to include('must be filled')
    end

    it 'fails when month_day is out of range' do
      rule.month_day = 40
      expect(result).to be_failure
      expect(result.errors.to_h).to have_key(:month_day)
    end
  end

  context 'when month_parity' do
    let(:rule) { build(:recurring_rule, :month_parity) }

    it 'succeeds for a valid rule' do
      expect(result).to be_success
    end

    it 'requires parity' do
      rule.parity = nil
      expect(result.errors[:parity]).to include('must be filled')
    end

    it 'fails when parity is unknown' do
      rule.parity = 'weekend'
      expect(result).to be_failure
      expect(result.errors.to_h).to have_key(:parity)
    end
  end

  context 'when specific_dates' do
    let(:rule) { build(:recurring_rule, :specific_dates) }

    it 'succeeds for a valid rule' do
      expect(result).to be_success
    end

    it 'requires dates' do
      rule.dates = []
      expect(result.errors[:dates]).to include('must be filled')
    end

    it 'fails when dates contains a blank element' do
      rule.dates = [Date.new(2024, 1, 1), nil]
      expect(result).to be_failure
      expect(result.errors[:dates]).to include('cant contain blank dates')
    end
  end
end

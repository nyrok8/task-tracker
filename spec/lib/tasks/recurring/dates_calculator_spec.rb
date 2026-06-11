# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tasks::Recurring::DatesCalculator do
  subject(:dates) { described_class.new(rule).call(period) }

  context 'when daily' do
    let(:rule) { build(:recurring_rule, :daily, starts_on: Date.new(2026, 6, 1), day_interval: 1) }
    let(:period) { Date.new(2026, 6, 1)..Date.new(2026, 6, 4) }

    it 'returns every day of the period from starts_on' do
      expect(dates).to eq([Date.new(2026, 6, 1), Date.new(2026, 6, 2), Date.new(2026, 6, 3), Date.new(2026, 6, 4)])
    end
  end

  context 'when daily with an interval' do
    let(:rule) { build(:recurring_rule, :daily, starts_on: Date.new(2026, 6, 1), day_interval: 2) }
    let(:period) { Date.new(2026, 6, 1)..Date.new(2026, 6, 7) }

    it 'returns every n-th day' do
      expect(dates).to eq([Date.new(2026, 6, 1), Date.new(2026, 6, 3), Date.new(2026, 6, 5), Date.new(2026, 6, 7)])
    end
  end

  context 'when the period starts after starts_on' do
    let(:rule) { build(:recurring_rule, :daily, starts_on: Date.new(2026, 6, 1)) }
    let(:period) { Date.new(2026, 6, 3)..Date.new(2026, 6, 5) }

    it 'clips to the period' do
      expect(dates).to eq([Date.new(2026, 6, 3), Date.new(2026, 6, 4), Date.new(2026, 6, 5)])
    end
  end

  context 'when the period is entirely before starts_on' do
    let(:rule) { build(:recurring_rule, :daily, starts_on: Date.new(2026, 6, 10)) }
    let(:period) { Date.new(2026, 6, 1)..Date.new(2026, 6, 5) }

    it 'is empty' do
      expect(dates).to be_empty
    end
  end

  context 'when monthly on a fixed day' do
    let(:rule) { build(:recurring_rule, :monthly_day, starts_on: Date.new(2026, 1, 1), month_day: 15) }
    let(:period) { Date.new(2026, 1, 1)..Date.new(2026, 3, 31) }

    it 'returns that day each month' do
      expect(dates).to eq([Date.new(2026, 1, 15), Date.new(2026, 2, 15), Date.new(2026, 3, 15)])
    end
  end

  context 'when the monthly day exceeds shorter months' do
    let(:rule) { build(:recurring_rule, :monthly_day, starts_on: Date.new(2026, 1, 1), month_day: 31) }
    let(:period) { Date.new(2026, 1, 1)..Date.new(2026, 4, 30) }

    it 'clamps to the last day of each month' do
      expect(dates).to eq([Date.new(2026, 1, 31), Date.new(2026, 2, 28), Date.new(2026, 3, 31), Date.new(2026, 4, 30)])
    end
  end

  context 'when the monthly day exceeds a leap February' do
    let(:rule) { build(:recurring_rule, :monthly_day, starts_on: Date.new(2024, 2, 1), month_day: 31) }
    let(:period) { Date.new(2024, 2, 1)..Date.new(2024, 2, 29) }

    it 'clamps to February 29th' do
      expect(dates).to eq([Date.new(2024, 2, 29)])
    end
  end

  context 'when the monthly day precedes starts_on in the first month' do
    let(:rule) { build(:recurring_rule, :monthly_day, starts_on: Date.new(2026, 1, 20), month_day: 15) }
    let(:period) { Date.new(2026, 1, 1)..Date.new(2026, 3, 31) }

    it 'skips that first month' do
      expect(dates).to eq([Date.new(2026, 2, 15), Date.new(2026, 3, 15)])
    end
  end

  context 'when month parity is even' do
    let(:rule) { build(:recurring_rule, :month_parity, starts_on: Date.new(2026, 6, 1), parity: 'even') }
    let(:period) { Date.new(2026, 6, 1)..Date.new(2026, 6, 6) }

    it 'returns the even days of the month' do
      expect(dates).to eq([Date.new(2026, 6, 2), Date.new(2026, 6, 4), Date.new(2026, 6, 6)])
    end
  end

  context 'when month parity is odd' do
    let(:rule) { build(:recurring_rule, :month_parity, starts_on: Date.new(2026, 6, 1), parity: 'odd') }
    let(:period) { Date.new(2026, 6, 1)..Date.new(2026, 6, 6) }

    it 'returns the odd days of the month' do
      expect(dates).to eq([Date.new(2026, 6, 1), Date.new(2026, 6, 3), Date.new(2026, 6, 5)])
    end
  end

  context 'when specific dates' do
    let(:rule) { build(:recurring_rule, :specific_dates, dates: [Date.new(2026, 2, 20), Date.new(2026, 1, 15)]) }
    let(:period) { Date.new(2026, 1, 1)..Date.new(2026, 3, 31) }

    it 'returns the listed dates sorted' do
      expect(dates).to eq([Date.new(2026, 1, 15), Date.new(2026, 2, 20)])
    end
  end

  context 'when specific dates fall outside the period' do
    let(:rule) { build(:recurring_rule, :specific_dates, dates: [Date.new(2026, 1, 15), Date.new(2026, 2, 20)]) }
    let(:period) { Date.new(2026, 1, 1)..Date.new(2026, 1, 31) }

    it 'keeps only those inside the period' do
      expect(dates).to eq([Date.new(2026, 1, 15)])
    end
  end

  context 'when specific dates precede starts_on' do
    let(:rule) do
      build(:recurring_rule, :specific_dates, starts_on: Date.new(2026, 2, 1),
        dates: [Date.new(2026, 1, 15), Date.new(2026, 2, 20)])
    end
    let(:period) { Date.new(2026, 1, 1)..Date.new(2026, 3, 31) }

    it 'skips the dates before starts_on' do
      expect(dates).to eq([Date.new(2026, 2, 20)])
    end
  end

  context 'when bounded by ends_on' do
    let(:rule) { build(:recurring_rule, :daily, starts_on: Date.new(2026, 6, 1), ends_on: Date.new(2026, 6, 3)) }
    let(:period) { Date.new(2026, 6, 1)..Date.new(2026, 6, 10) }

    it 'stops at ends_on' do
      expect(dates).to eq([Date.new(2026, 6, 1), Date.new(2026, 6, 2), Date.new(2026, 6, 3)])
    end
  end

  context 'when bounded by max_count' do
    let(:rule) { build(:recurring_rule, :daily, starts_on: Date.new(2026, 6, 1), max_count: 3) }
    let(:period) { Date.new(2026, 6, 1)..Date.new(2026, 6, 10) }

    it 'returns at most max_count occurrences' do
      expect(dates).to eq([Date.new(2026, 6, 1), Date.new(2026, 6, 2), Date.new(2026, 6, 3)])
    end
  end

  context 'when max_count is exhausted before the period' do
    let(:rule) { build(:recurring_rule, :daily, starts_on: Date.new(2026, 6, 1), max_count: 3) }
    let(:period) { Date.new(2026, 6, 5)..Date.new(2026, 6, 10) }

    it 'is empty because the counted occurrences are earlier' do
      expect(dates).to be_empty
    end
  end

  context 'when the recurrence type is unknown' do
    let(:rule) { build(:recurring_rule, recurrence_type: 'weekly') }
    let(:period) { Date.new(2026, 6, 1)..Date.new(2026, 6, 5) }

    it 'returns no dates' do
      expect(dates).to be_empty
    end
  end

  context 'with far-apart time zones' do
    let(:rule) { build(:recurring_rule, :daily, starts_on: Date.new(2026, 6, 1)) }
    let(:period) { Date.new(2026, 6, 1)..Date.new(2026, 6, 3) }

    it 'computes the same dates regardless of Time.zone' do
      east = Time.use_zone('Kamchatka') { described_class.new(rule).call(period) }
      west = Time.use_zone('Hawaii') { described_class.new(rule).call(period) }
      expect(east).to eq([Date.new(2026, 6, 1), Date.new(2026, 6, 2), Date.new(2026, 6, 3)])
      expect(west).to eq(east)
    end
  end
end

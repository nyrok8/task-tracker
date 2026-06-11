# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tasks::Recurring::OccurrenceQuery do
  let(:assignee) { create(:user) }
  let(:template) { create(:recurring_template, scheduled_at: Time.zone.local(2026, 6, 1, 10)) }

  before { create(:recurring_rule, :daily, template:, starts_on: Date.new(2026, 6, 1)) }

  describe '#call' do
    subject(:occurrences) { described_class.new([template], period).call }

    let(:period) { Time.zone.local(2026, 6, 10)..Time.zone.local(2026, 6, 12, 23, 59, 59) }

    context 'with overrides in the window' do
      let(:expected_result) do
        [
          {
            id: nil,
            template_id: template.id,
            date_key: Date.new(2026, 6, 10),
            name: 'Daily rounds',
            description: 'Daily patient rounds',
            scheduled_at: Time.zone.local(2026, 6, 10, 10),
            status: 'pending',
            assignee_id: nil,
            tags: []
          },
          {
            id: nil,
            template_id: template.id,
            date_key: Date.new(2026, 6, 12),
            name: 'Urgent rounds',
            description: 'Urgent patient rounds',
            scheduled_at: Time.zone.local(2026, 6, 12, 15),
            status: 'done',
            assignee_id: assignee.id,
            tags: ['urgent']
          }
        ]
      end

      before do
        create(:recurring_override, template:, date_key: Date.new(2026, 6, 11), deleted_at: Time.current)
        create(:recurring_override, template:,
          date_key: Date.new(2026, 6, 12),
          name: 'Urgent rounds',
          description: 'Urgent patient rounds',
          scheduled_at: Time.zone.local(2026, 6, 12, 15),
          status: 'done',
          assignee:,
          tags: ['urgent'])
      end

      it 'dates scheduled_at to each occurrence, overlays overrides, and skips tombstones' do
        expect(occurrences.map { |o| o.attributes.symbolize_keys }).to match_array(expected_result)
      end
    end

    context 'when an occurrence is moved out of the window' do
      before do
        create(:recurring_override, template:, date_key: Date.new(2026, 6, 10),
          scheduled_at: Time.zone.local(2026, 7, 1, 10))
      end

      it 'drops it from the window' do
        expect(occurrences.map(&:date_key)).not_to include(Date.new(2026, 6, 10))
      end
    end

    context 'when an occurrence is moved into the window' do
      before do
        create(:recurring_override, template:, date_key: Date.new(2026, 6, 5),
          scheduled_at: Time.zone.local(2026, 6, 11, 14))
      end

      it 'includes it by its scheduled_at while keeping its date_key' do
        moved = occurrences.detect { |o| o.date_key == Date.new(2026, 6, 5) }
        expect(moved&.scheduled_at).to eq(Time.zone.local(2026, 6, 11, 14))
      end
    end

    context 'with several templates' do
      subject(:occurrences) { described_class.new([template, other_template], period).call }

      let(:other_template) { create(:recurring_template, scheduled_at: Time.zone.local(2026, 6, 1, 10)) }

      before do
        create(:recurring_rule, :daily, template: other_template, starts_on: Date.new(2026, 6, 1))
        create(:recurring_override, template:, date_key: Date.new(2026, 6, 10), name: 'Mine')
        create(:recurring_override, template: other_template, date_key: Date.new(2026, 6, 10), name: 'Theirs')
      end

      it 'attaches each override to its own template' do
        on_10 = occurrences.select { |o| o.date_key == Date.new(2026, 6, 10) }.map { |o| [o.template_id, o.name] }
        expect(on_10).to contain_exactly([template.id, 'Mine'], [other_template.id, 'Theirs'])
      end
    end

    context 'when nothing falls in the window' do
      let(:period) { Time.zone.local(2025, 1, 1)..Time.zone.local(2025, 1, 2) }

      it 'is empty' do
        expect(occurrences).to be_empty
      end
    end

    context 'with a near-midnight template time' do
      let(:template) { create(:recurring_template, scheduled_at: Time.zone.local(2026, 6, 1, 0, 30)) }
      let(:period) { Time.zone.local(2026, 6, 10)..Time.zone.local(2026, 6, 10, 23, 59, 59) }

      it 'keeps the occurrence inside its local day' do
        expect(occurrences.sole.scheduled_at).to eq(Time.zone.local(2026, 6, 10, 0, 30))
      end
    end

    context 'when the rule ended before the period' do
      subject(:occurrences) { described_class.new([ended_template], period).call }

      let(:ended_template) { create(:recurring_template, scheduled_at: Time.zone.local(2026, 6, 1, 10)) }

      before do
        create(:recurring_rule, :daily, template: ended_template,
          starts_on: Date.new(2026, 6, 1), ends_on: Date.new(2026, 6, 5))
        create(:recurring_override, template: ended_template, date_key: Date.new(2026, 6, 3),
          scheduled_at: Time.zone.local(2026, 6, 11, 9))
      end

      it 'still finds occurrences moved into the period' do
        expect(occurrences.sole.date_key).to eq(Date.new(2026, 6, 3))
      end
    end
  end

  describe '.at' do
    it 'returns the occurrence addressed by its date_key' do
      expect(described_class.at(template, Date.new(2026, 6, 11)).take.date_key).to eq(Date.new(2026, 6, 11))
    end

    it 'is empty for a date the rule does not produce' do
      expect(described_class.at(template, Date.new(2026, 5, 31))).to be_empty
    end
  end
end

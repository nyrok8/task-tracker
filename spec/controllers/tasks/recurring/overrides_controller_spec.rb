# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tasks::Recurring::OverridesController, type: :controller do
  describe '#update' do
    subject(:update_request) { patch :update, params: }

    let(:template) { create(:recurring_template, scheduled_at: Time.zone.local(2026, 6, 1, 10)) }
    let(:assignee) { create(:user) }
    let(:override_params) do
      {
        name: 'Urgent rounds',
        description: 'Emergency ward round',
        scheduled_at: '2026-06-10T15:30:00',
        status: 'done',
        assignee_id: assignee.id,
        tags: ['urgent']
      }
    end
    let(:params) { { template_id: template.id, id: '2026-06-09', override: override_params } }

    before do
      create(:recurring_rule, :daily, template:, starts_on: Date.new(2026, 6, 1))
      create(:tag, name: 'urgent')
    end

    it 'persists the full override delta' do
      expect { update_request }.to change { template.overrides.count }.by(1)
      override = template.overrides.sole
      expect(override.date_key).to eq(Date.new(2026, 6, 9))
      expect(override.scheduled_at).to eq(Time.zone.local(2026, 6, 10, 15, 30))
      expect(override.slice(:name, :description, :status, :assignee_id, :tags).symbolize_keys)
        .to eq(override_params.except(:scheduled_at))
    end

    it 'responds with the merged occurrence' do
      update_request
      expect(response).to have_http_status(:ok)
      expect(Time.zone.parse(response.parsed_body['scheduled_at'])).to eq(Time.zone.local(2026, 6, 10, 15, 30))
      expect(response.parsed_body).to include(
        'template_id' => template.id,
        'date_key' => '2026-06-09',
        'name' => 'Urgent rounds',
        'description' => 'Emergency ward round',
        'status' => 'done',
        'assignee_id' => assignee.id,
        'tags' => ['urgent']
      )
    end

    context 'when params are invalid' do
      let(:override_params) { { status: 'unknown' } }

      it 'persists nothing and responds with 422' do
        expect { update_request }.not_to change { template.overrides.count }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body['errors']).to have_key('status')
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe 'overrides#update', openapi: { tags: %w[Overrides] }, type: :request do
  subject(:make_request) do
    patch "/tasks/recurring/templates/#{template.id}/overrides/2026-06-09", params: { override: override_params },
      as: :json
  end

  let(:template) { create(:recurring_template, scheduled_at: Time.zone.local(2026, 6, 1, 10)) }
  let(:override_params) { { status: 'done' } }

  before { create(:recurring_rule, :daily, template:, starts_on: Date.new(2026, 6, 1)) }

  it 'overrides the occurrence and responds with it' do
    expect { make_request }.to change { template.overrides.count }.by(1)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['status']).to eq('done')
  end

  context 'when params are invalid' do
    let(:override_params) { { status: 'unknown' } }

    it 'responds with 422' do
      expect { make_request }.not_to change { template.overrides.count }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors']).to be_present
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe 'overrides#show', openapi: { tags: %w[Overrides] }, type: :request do
  subject(:make_request) { get "/tasks/recurring/templates/#{template.id}/overrides/#{date_key}" }

  let(:template) { create(:recurring_template, scheduled_at: Time.zone.local(2026, 6, 1, 10)) }
  let(:date_key) { '2026-06-09' }

  before { create(:recurring_rule, :daily, template:, starts_on: Date.new(2026, 6, 1)) }

  it 'responds with the occurrence' do
    make_request
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['date_key']).to eq(date_key)
  end

  context 'when the rule does not produce the date' do
    let(:date_key) { '2026-05-31' }

    it 'responds with 404' do
      make_request
      expect(response).to have_http_status(:not_found)
    end
  end
end

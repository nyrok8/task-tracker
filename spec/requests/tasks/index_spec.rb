# frozen_string_literal: true

require 'rails_helper'

describe 'tasks#index', openapi: { tags: %w[Tasks] }, type: :request do
  subject(:make_request) { get '/tasks', params: }

  let(:params) { { from: '2026-06-09T00:00:00', to: '2026-06-10T23:59:59' } }
  let(:template) { create(:recurring_template, scheduled_at: Time.zone.local(2026, 6, 1, 10)) }

  before do
    create(:recurring_rule, :daily, template:, starts_on: Date.new(2026, 6, 1))
    create(:one_off, scheduled_at: Time.zone.local(2026, 6, 9, 8))
  end

  it 'responds with the merged task list' do
    make_request
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.size).to eq(3)
  end

  context 'when filtering' do
    let(:params) { { from: '2026-06-09T00:00:00', to: '2026-06-10T23:59:59', q: { status: 'done' }} }

    it 'responds with the filtered list' do
      make_request
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to be_empty
    end
  end

  context 'when the period is malformed' do
    let(:params) { { from: 'invalid', to: '2026-06-10T23:59:59' } }

    it 'responds with 400' do
      make_request
      expect(response).to have_http_status(:bad_request)
    end
  end
end

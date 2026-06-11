# frozen_string_literal: true

require 'rails_helper'

describe 'templates#create', openapi: { tags: %w[Templates] }, type: :request do
  subject(:make_request) { post '/tasks/recurring/templates', params: { template:, rule: }, as: :json }

  let(:template) do
    { name: 'Daily rounds', description: 'Daily patient rounds', scheduled_at: '2026-06-01T10:00:00' }
  end
  let(:rule) { { recurrence_type: 'daily', starts_on: '2026-06-01', day_interval: 1 } }

  it 'creates the template with its rule and responds with 201' do
    expect { make_request }.to change { Tasks::Recurring::Template.count }.by(1)
    expect(response).to have_http_status(:created)
  end

  context 'when params are invalid' do
    let(:rule) { { recurrence_type: 'daily', day_interval: 1 } }

    it 'responds with 422' do
      expect { make_request }.not_to change { Tasks::Recurring::Template.count }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors']).to be_present
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe 'one_offs#create', openapi: { tags: %w[OneOffs] }, type: :request do
  subject(:make_request) { post '/tasks/one_offs', params: { one_off: one_off_params }, as: :json }

  let(:one_off_params) do
    { name: 'Patient round', description: 'Morning ward round', scheduled_at: '2026-06-09T08:00:00' }
  end

  it 'creates the task and responds with 201' do
    expect { make_request }.to change { Tasks::OneOff.count }.by(1)
    expect(response).to have_http_status(:created)
  end

  context 'when params are invalid' do
    let(:one_off_params) { { name: '', description: 'Morning ward round', scheduled_at: '2026-06-09T08:00:00' } }

    it 'responds with 422' do
      expect { make_request }.not_to change { Tasks::OneOff.count }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors']).to be_present
    end
  end
end

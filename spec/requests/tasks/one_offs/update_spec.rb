# frozen_string_literal: true

require 'rails_helper'

describe 'one_offs#update', openapi: { tags: %w[OneOffs] }, type: :request do
  subject(:make_request) { patch "/tasks/one_offs/#{one_off.id}", params: { one_off: one_off_params }, as: :json }

  let(:one_off) { create(:one_off) }
  let(:one_off_params) { { status: 'done' } }

  it 'updates the task' do
    make_request
    expect(response).to have_http_status(:ok)
    expect(one_off.reload.status).to eq('done')
  end

  context 'when params are invalid' do
    let(:one_off_params) { { status: 'unknown' } }

    it 'responds with 422' do
      make_request
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors']).to be_present
    end
  end
end

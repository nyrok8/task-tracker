# frozen_string_literal: true

require 'rails_helper'

describe 'users#update', openapi: { tags: %w[Users] }, type: :request do
  subject(:make_request) { patch "/users/#{user.id}", params: { user: user_params }, as: :json }

  let(:user) { create(:user) }
  let(:user_params) { { name: 'Morty Smith' } }

  it 'updates the user' do
    make_request
    expect(response).to have_http_status(:ok)
    expect(user.reload.name).to eq('Morty Smith')
  end

  context 'when params are invalid' do
    let(:user_params) { { name: '' } }

    it 'responds with 422' do
      make_request
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors']).to be_present
    end
  end
end

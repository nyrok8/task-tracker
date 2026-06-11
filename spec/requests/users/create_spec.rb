# frozen_string_literal: true

require 'rails_helper'

describe 'users#create', openapi: { tags: %w[Users] }, type: :request do
  subject(:make_request) { post '/users', params: { user: user_params }, as: :json }

  let(:user_params) { { name: 'Rick Sanchez' } }

  it 'creates the user and responds with 201' do
    expect { make_request }.to change { User.count }.by(1)
    expect(response).to have_http_status(:created)
  end

  context 'when params are invalid' do
    let(:user_params) { { name: '' } }

    it 'responds with 422' do
      expect { make_request }.not_to change { User.count }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors']).to be_present
    end
  end
end

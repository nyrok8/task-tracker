# frozen_string_literal: true

require 'rails_helper'

describe 'users#show', openapi: { tags: %w[Users] }, type: :request do
  subject(:make_request) { get "/users/#{user.id}" }

  let(:user) { create(:user) }

  it 'responds with the user' do
    make_request
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['id']).to eq(user.id)
  end
end

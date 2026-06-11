# frozen_string_literal: true

require 'rails_helper'

describe 'users#index', openapi: { tags: %w[Users] }, type: :request do
  subject(:make_request) { get '/users' }

  before { create(:user) }

  it 'responds with the user list' do
    make_request
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.size).to eq(1)
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe 'tags#index', openapi: { tags: %w[Tags] }, type: :request do
  subject(:make_request) { get '/tags' }

  before { create(:tag) }

  it 'responds with the tag list' do
    make_request
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.size).to eq(1)
  end
end

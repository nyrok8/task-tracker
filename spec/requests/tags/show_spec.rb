# frozen_string_literal: true

require 'rails_helper'

describe 'tags#show', openapi: { tags: %w[Tags] }, type: :request do
  subject(:make_request) { get "/tags/#{tag.id}" }

  let(:tag) { create(:tag) }

  it 'responds with the tag' do
    make_request
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['id']).to eq(tag.id)
  end
end

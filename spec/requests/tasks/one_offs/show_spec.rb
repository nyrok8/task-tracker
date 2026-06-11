# frozen_string_literal: true

require 'rails_helper'

describe 'one_offs#show', openapi: { tags: %w[OneOffs] }, type: :request do
  subject(:make_request) { get "/tasks/one_offs/#{one_off.id}" }

  let(:one_off) { create(:one_off) }

  it 'responds with the task' do
    make_request
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['id']).to eq(one_off.id)
  end
end

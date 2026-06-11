# frozen_string_literal: true

require 'rails_helper'

describe 'tags#create', openapi: { tags: %w[Tags] }, type: :request do
  subject(:make_request) { post '/tags', params: { tag: tag_params }, as: :json }

  let(:tag_params) { { name: 'urgent' } }

  it 'creates the tag and responds with 201' do
    expect { make_request }.to change { Tag.count }.by(1)
    expect(response).to have_http_status(:created)
  end

  context 'when params are invalid' do
    let(:tag_params) { { name: '' } }

    it 'responds with 422' do
      expect { make_request }.not_to change { Tag.count }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors']).to be_present
    end
  end
end

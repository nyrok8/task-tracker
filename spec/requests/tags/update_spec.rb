# frozen_string_literal: true

require 'rails_helper'

describe 'tags#update', openapi: { tags: %w[Tags] }, type: :request do
  subject(:make_request) { patch "/tags/#{tag.id}", params: { tag: { name: 'renamed' }}, as: :json }

  let(:tag) { create(:tag) }

  it 'updates the tag' do
    make_request
    expect(response).to have_http_status(:ok)
    expect(tag.reload.name).to eq('renamed')
  end

  context 'when the tag is a system tag' do
    let(:tag) { create(:tag, system: true) }

    it 'responds with 422' do
      make_request
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors']).to be_present
    end
  end
end

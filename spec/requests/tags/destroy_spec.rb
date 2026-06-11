# frozen_string_literal: true

require 'rails_helper'

describe 'tags#destroy', openapi: { tags: %w[Tags] }, type: :request do
  subject(:make_request) { delete "/tags/#{tag.id}" }

  let(:tag) { create(:tag) }

  before { tag }

  it 'destroys the tag and responds with 204' do
    expect { make_request }.to change { Tag.count }.by(-1)
    expect(response).to have_http_status(:no_content)
  end

  context 'when the tag is a system tag' do
    let(:tag) { create(:tag, system: true) }

    it 'responds with 422' do
      expect { make_request }.not_to change { Tag.count }
      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors']).to be_present
    end
  end
end

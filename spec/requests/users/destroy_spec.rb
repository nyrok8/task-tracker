# frozen_string_literal: true

require 'rails_helper'

describe 'users#destroy', openapi: { tags: %w[Users] }, type: :request do
  subject(:make_request) { delete "/users/#{user.id}" }

  let(:user) { create(:user) }

  before { user }

  it 'destroys the user and responds with 204' do
    expect { make_request }.to change { User.count }.by(-1)
    expect(response).to have_http_status(:no_content)
  end
end

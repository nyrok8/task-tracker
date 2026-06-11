# frozen_string_literal: true

require 'rails_helper'

describe 'one_offs#destroy', openapi: { tags: %w[OneOffs] }, type: :request do
  subject(:make_request) { delete "/tasks/one_offs/#{one_off.id}" }

  let(:one_off) { create(:one_off) }

  before { one_off }

  it 'destroys the task and responds with 204' do
    expect { make_request }.to change { Tasks::OneOff.count }.by(-1)
    expect(response).to have_http_status(:no_content)
  end
end

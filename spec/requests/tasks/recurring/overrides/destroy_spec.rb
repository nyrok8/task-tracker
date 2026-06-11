# frozen_string_literal: true

require 'rails_helper'

describe 'overrides#destroy', openapi: { tags: %w[Overrides] }, type: :request do
  subject(:make_request) { delete "/tasks/recurring/templates/#{template.id}/overrides/2026-06-09" }

  let(:template) { create(:recurring_template, scheduled_at: Time.zone.local(2026, 6, 1, 10)) }

  before { create(:recurring_rule, :daily, template:, starts_on: Date.new(2026, 6, 1)) }

  it 'tombstones the occurrence and responds with 204' do
    make_request
    expect(response).to have_http_status(:no_content)
    expect(template.overrides.sole.deleted_at).to be_present
  end
end

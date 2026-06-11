# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TasksController, type: :controller do
  describe '#index' do
    subject(:index_request) { get :index, params: }

    let(:params) { { from: '2026-06-09', to: '2026-06-10' } }

    it 'responds with 200' do
      index_request
      expect(response).to have_http_status(:ok)
    end

    context 'when the status filter is not a valid status' do
      let(:params) { { from: '2026-06-09', to: '2026-06-10', q: { status: 'garbage' }} }

      it 'responds with 400' do
        index_request
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when statuses contain an unknown value' do
      let(:params) { { from: '2026-06-09', to: '2026-06-10', q: { statuses: %w[done garbage] }} }

      it 'responds with 400' do
        index_request
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when the period exceeds the limit' do
      let(:params) { { from: '2026-01-01', to: '2030-01-01' } }

      it 'responds with 400' do
        index_request
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when q is not a hash' do
      let(:params) { { from: '2026-06-09', to: '2026-06-10', q: 'done' } }

      it 'responds with 400' do
        index_request
        expect(response).to have_http_status(:bad_request)
      end
    end

    context 'when a period bound is not a string' do
      let(:params) { { from: ['2026-06-09'], to: '2026-06-10' } }

      it 'responds with 400' do
        index_request
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end

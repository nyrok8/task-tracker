# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagsController, type: :controller do
  describe '#destroy' do
    subject(:destroy) { delete :destroy, params: { id: tag.id } }

    before { tag }

    context 'when the tag is a system tag' do
      let(:tag) { create(:tag, system: true) }

      it 'refuses to delete it' do
        expect { destroy }.not_to change { Tag.count }
        expect(response).to have_http_status(:unprocessable_content)
        expect(response.parsed_body['errors']).to include('system tag cant be deleted')
      end
    end

    context 'when the tag is a regular tag' do
      let(:tag) { create(:tag) }

      it 'deletes it' do
        expect { destroy }.to change { Tag.count }.by(-1)
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end

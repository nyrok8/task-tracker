# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserContract do
  subject(:result) { described_class.new.call(user.attributes) }

  let(:user) { build(:user) }

  it 'succeeds for a valid user' do
    expect(result).to be_success
  end

  it 'fails when name is blank' do
    user.name = '   '
    expect(result).to be_failure
    expect(result.errors[:name]).to include('must be filled')
  end

  it 'fails when name exceeds 100 characters' do
    user.name = 'x' * 101
    expect(result).to be_failure
    expect(result.errors.to_h).to have_key(:name)
  end
end

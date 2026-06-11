# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TagContract do
  subject(:result) { described_class.new(tag:).call(tag.attributes) }

  let(:tag) { build(:tag) }

  it 'succeeds for a valid tag' do
    expect(result).to be_success
  end

  it 'fails when name is blank' do
    tag.name = '   '
    expect(result).to be_failure
    expect(result.errors[:name]).to include('must be filled')
  end

  it 'fails when name exceeds 32 characters' do
    tag.name = 'x' * 33
    expect(result).to be_failure
    expect(result.errors.to_h).to have_key(:name)
  end

  it 'fails when the name is already taken' do
    create(:tag, name: 'reporting')
    tag.name = 'reporting'
    expect(result).to be_failure
    expect(result.errors[:name]).to include('has already been taken')
  end

  it 'allows a tag to keep its own name' do
    tag.save!
    expect(result).to be_success
  end

  context 'when the tag is a system tag' do
    let(:tag) { create(:tag, system: true) }

    it 'cannot be modified' do
      expect(result).to be_failure
      expect(result.errors[:name]).to include('system tag cant be modified')
    end
  end
end

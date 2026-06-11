# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TaskContract do
  subject(:result) { described_class.new(record:).call(record.attributes) }

  let(:record) { build(:one_off) }

  it 'succeeds for a valid task' do
    expect(result).to be_success
  end

  it 'validates required fields' do
    record.assign_attributes(name: nil, description: nil, scheduled_at: nil)
    expect(result.errors[:name]).to include('must be filled')
    expect(result.errors[:description]).to include('must be filled')
    expect(result.errors[:scheduled_at]).to include('must be filled')
  end

  it 'fails when name exceeds 64 characters' do
    record.name = 'x' * 65
    expect(result).to be_failure
    expect(result.errors.to_h).to have_key(:name)
  end

  it 'fails when description exceeds 255 characters' do
    record.description = 'x' * 256
    expect(result).to be_failure
    expect(result.errors.to_h).to have_key(:description)
  end

  it 'fails when status is unknown' do
    record.status = 'archived'
    expect(result).to be_failure
    expect(result.errors.to_h).to have_key(:status)
  end

  it 'fails when assignee does not exist' do
    record.assignee_id = 123_456
    expect(result).to be_failure
    expect(result.errors.to_h).to have_key(:assignee_id)
  end

  it 'fails when a tag is not in the registry' do
    create(:tag, name: 'reporting')
    record.tags = %w[reporting ghost]
    expect(result).to be_failure
    expect(result.errors.to_h).to have_key(:tags)
  end

  it 'accepts registered tags' do
    create(:tag, name: 'reporting')
    record.tags = ['reporting']
    expect(result).to be_success
  end

  context 'when record is Tasks::Recurring::Override' do
    let(:record) { build(:recurring_override) }

    it 'validates required fields' do
      record.assign_attributes(name: nil, description: nil, scheduled_at: nil)
      expect(result).to be_success
    end
  end
end

# frozen_string_literal: true

class UserContract < Dry::Validation::Contract
  json do
    optional(:name).maybe(:string, max_size?: 100)
  end

  rule(:name) do
    key.failure('must be filled') if value.blank?
  end
end

# frozen_string_literal: true

class TagContract < Dry::Validation::Contract
  option :tag

  json do
    optional(:name).maybe(:string, max_size?: 32)
  end

  rule(:name) do
    key.failure('system tag cant be modified') if tag.system?
  end

  rule(:name) do
    key.failure('must be filled') if value.blank?
  end

  rule(:name) do
    next if value.blank?

    key.failure('has already been taken') if Tag.where(name: value).where.not(id: tag.id).exists?
  end
end

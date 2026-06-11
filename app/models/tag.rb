# frozen_string_literal: true

class Tag < ApplicationRecord
  def self.names
    @names ||= pluck(:name)
  end

  def self.reset_names
    @names = nil
  end
end

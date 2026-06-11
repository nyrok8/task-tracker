# frozen_string_literal: true

module Tasks
  module Recurring
    class Template < ApplicationRecord
      belongs_to :assignee, class_name: 'User', optional: true
      has_one :rule, dependent: :destroy
      has_many :overrides, dependent: :destroy
    end
  end
end

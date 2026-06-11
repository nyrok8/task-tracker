# frozen_string_literal: true

module Tasks
  class OneOff < ApplicationRecord
    include Tasks::Filterable

    belongs_to :assignee, class_name: 'User', optional: true
  end
end

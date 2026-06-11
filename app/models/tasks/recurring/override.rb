# frozen_string_literal: true

module Tasks
  module Recurring
    class Override < ApplicationRecord
      belongs_to :template
      belongs_to :assignee, class_name: 'User', optional: true
    end
  end
end

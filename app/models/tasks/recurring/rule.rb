# frozen_string_literal: true

module Tasks
  module Recurring
    class Rule < ApplicationRecord
      RECURRENCE_TYPES = [
        DAILY = 'daily',
        MONTHLY_DAY = 'monthly_day',
        MONTH_PARITY = 'month_parity',
        SPECIFIC_DATES = 'specific_dates'
      ].freeze

      PARITIES = [
        EVEN = 'even',
        ODD = 'odd'
      ].freeze

      belongs_to :template
    end
  end
end

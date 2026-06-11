# frozen_string_literal: true

module Tasks
  module Recurring
    class Occurrence < ApplicationRecord
      include Tasks::Filterable

      self.table_name = 'tasks_recurring_overrides'

      def self.ransackable_attributes(_auth = nil)
        super + %w[template_id date_key]
      end

      def readonly? = true
    end
  end
end

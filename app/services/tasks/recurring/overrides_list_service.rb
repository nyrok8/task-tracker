# frozen_string_literal: true

module Tasks
  module Recurring
    class OverridesListService
      include Tasks::SearchFilters

      FILTERS = Tasks::SearchFilters::FILTERS.merge(template_id: :template_id_eq).freeze

      def initialize(templates, period, search_params = {})
        @templates = templates
        @period = period
        @search_params = search_params.to_h.symbolize_keys
      end

      def call
        scope.ransack(filters).result
      end

      private

      def scope
        OccurrenceQuery.new(@templates, @period).call
      end
    end
  end
end

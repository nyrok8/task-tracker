# frozen_string_literal: true

module Tasks
  class OneOffsListService
    include Tasks::SearchFilters

    def initialize(period, search_params = {})
      @period = period
      @search_params = search_params.to_h.symbolize_keys
    end

    def call
      return OneOff.none if @search_params[:template_id].present?

      scope.ransack(filters).result
    end

    private

    def scope
      OneOff.where(scheduled_at: @period)
    end
  end
end

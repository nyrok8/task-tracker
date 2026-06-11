# frozen_string_literal: true

module Tasks
  module SearchFilters
    FILTERS = {
      status: :status_eq,
      statuses: :status_in,
      assignee_id: :assignee_id_eq,
      query: :name_or_description_cont,
      tag: :ransack_tagged_with
    }.freeze

    private

    def filters
      self.class::FILTERS.each_with_object({}) do |(param, predicate), query|
        value = @search_params[param]
        query[predicate] = value if value.present?
      end
    end
  end
end

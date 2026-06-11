# frozen_string_literal: true

module Tasks
  module Filterable
    extend ActiveSupport::Concern

    included do
      scope :ransack_tagged_with, -> (tag) { where('tags::text[] @> ARRAY[?]::text[]', tag) }
    end

    class_methods do
      def ransackable_attributes(_auth = nil)
        (Tasks::ATTRIBUTES - [:tags]).map(&:to_s)
      end

      def ransackable_scopes(_auth = nil)
        %w[ransack_tagged_with]
      end

      def ransackable_associations(_auth = nil)
        []
      end
    end
  end
end

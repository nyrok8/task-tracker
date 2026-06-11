# frozen_string_literal: true

module Tasks
  module Recurring
    class OverridesController < ApplicationController
      include TaskParams

      before_action :find_template
      before_action :require_occurrence, only: %i[show update destroy]

      def show
        render json: occurrence.take
      end

      def update
        override = @template.overrides.find_or_initialize_by(date_key:)
        override.assign_attributes(task_params(:override))
        validation = TaskContract.new(record: override).call(override.attributes)
        if validation.success?
          override.save!
          render json: occurrence.take
        else
          render json: { errors: validation.errors.to_h }, status: :unprocessable_content
        end
      end

      def destroy
        @template.overrides.find_or_initialize_by(date_key:).update!(deleted_at: Time.current)
        head :no_content
      end

      private

      def find_template
        @template = Template.find(params.expect(:template_id))
      end

      def require_occurrence
        head :not_found unless date_key && occurrence.exists?
      end

      def occurrence
        OccurrenceQuery.at(@template, date_key)
      end

      def date_key
        Date.iso8601(params.expect(:id))
      rescue Date::Error
        nil
      end
    end
  end
end

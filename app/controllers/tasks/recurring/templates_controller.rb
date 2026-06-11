# frozen_string_literal: true

module Tasks
  module Recurring
    class TemplatesController < ApplicationController
      include TaskParams

      def create
        result = CreateService.new(template_params: task_params(:template), rule_params:).call
        if result.success?
          render json: result.template, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_content
        end
      end

      private

      def rule_params
        params.expect(rule: [
          :recurrence_type, :starts_on, :ends_on, :max_count, :day_interval, :month_day, :parity, { dates: [] }
        ])
      end
    end
  end
end

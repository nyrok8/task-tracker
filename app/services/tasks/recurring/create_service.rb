# frozen_string_literal: true

module Tasks
  module Recurring
    class CreateService
      COMMON_RULE_PARAMS = %i[recurrence_type starts_on ends_on max_count].freeze
      TYPE_FIELD = {
        Rule::DAILY => :day_interval,
        Rule::MONTHLY_DAY => :month_day,
        Rule::MONTH_PARITY => :parity,
        Rule::SPECIFIC_DATES => :dates
      }.freeze

      Result = Struct.new(:template, :errors) do
        def success? = errors.empty?
      end

      def initialize(template_params:, rule_params:)
        @template_params = template_params
        @rule_params = rule_params
      end

      def call
        template = Template.new(@template_params)
        rule = template.build_rule(relevant_rule_params)
        errors = validation_errors(template, rule)
        ApplicationRecord.transaction { template.save! } if errors.empty?
        Result.new(template, errors)
      end

      private

      def relevant_rule_params
        @rule_params.slice(*COMMON_RULE_PARAMS, TYPE_FIELD[@rule_params[:recurrence_type]])
      end

      def validation_errors(template, rule)
        template_errors = TaskContract.new(record: template).call(template.attributes).errors.to_h
        rule_errors = RecurringRuleContract.new.call(rule.attributes).errors.to_h
        template_errors.merge(rule_errors)
      end
    end
  end
end

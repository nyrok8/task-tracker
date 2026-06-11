# frozen_string_literal: true

module Tasks
  module Recurring
    class DatesCalculator
      def initialize(rule)
        @rule = rule
      end

      def call(period)
        case @rule.recurrence_type
        when Rule::DAILY then schedule_dates(IceCube::Rule.daily(@rule.day_interval), period)
        when Rule::MONTH_PARITY then schedule_dates(IceCube::Rule.monthly.day_of_month(*parity_days), period)
        when Rule::SPECIFIC_DATES then clip(bound(distinct_dates), period)
        when Rule::MONTHLY_DAY then clip(bound(monthly_day_dates(period)), period)
        else []
        end
      end

      private

      def schedule_dates(recurrence, period)
        schedule = IceCube::Schedule.new(@rule.starts_on.in_time_zone)
        schedule.add_recurrence_rule(natively_bound(recurrence))
        schedule.occurrences_between(period.begin.in_time_zone, period.end.end_of_day).map(&:to_date)
      end

      def natively_bound(recurrence)
        recurrence = recurrence.until(@rule.ends_on.end_of_day) if @rule.ends_on
        recurrence = recurrence.count(@rule.max_count) if @rule.max_count
        recurrence
      end

      def distinct_dates
        Array(@rule.dates).uniq.select { |date| date >= @rule.starts_on }.sort
      end

      def monthly_day_dates(period)
        anchors = month_anchors(period).map { |month| clamp_to_month(month) }
        anchors.select { |date| date >= @rule.starts_on }
      end

      def month_anchors(period)
        ceiling = [@rule.ends_on, period.end].compact.min
        first = @rule.starts_on.beginning_of_month
        (0..).lazy.map { |offset| first >> offset }.take_while { |month| month <= ceiling }.to_a
      end

      def clamp_to_month(month)
        day = [@rule.month_day, Time.days_in_month(month.month, month.year)].min
        Date.new(month.year, month.month, day)
      end

      def parity_days
        (1..31).select { |day| (@rule.parity == 'even') ? day.even? : day.odd? }
      end

      def bound(dates)
        dates = dates.select { |date| date <= @rule.ends_on } if @rule.ends_on
        dates = dates.first(@rule.max_count) if @rule.max_count
        dates
      end

      def clip(dates, period)
        dates.select { |date| period.cover?(date) }.sort
      end
    end
  end
end

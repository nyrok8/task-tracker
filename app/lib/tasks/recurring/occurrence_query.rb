# frozen_string_literal: true

module Tasks
  module Recurring
    class OccurrenceQuery
      MERGE_SQL = <<~SQL.squish
        SELECT p.template_id,
               p.date_key,
               COALESCE(o.name, t.name)               AS name,
               COALESCE(o.description, t.description) AS description,
               COALESCE(o.scheduled_at,
                 (p.date_key + (t.scheduled_at AT TIME ZONE %<tz>s)::time) AT TIME ZONE %<tz>s) AS scheduled_at,
               COALESCE(o.status, t.status)           AS status,
               COALESCE(o.assignee_id, t.assignee_id) AS assignee_id,
               COALESCE(o.tags, t.tags)               AS tags
        FROM jsonb_to_recordset(%<pairs>s::jsonb) AS p(template_id bigint, date_key date)
        JOIN tasks_recurring_templates t ON t.id = p.template_id
        LEFT JOIN tasks_recurring_overrides o
          ON o.template_id = p.template_id AND o.date_key = p.date_key
        WHERE o.id IS NULL OR o.deleted_at IS NULL
        ORDER BY p.date_key, p.template_id
      SQL

      class << self
        def at(template, date_key)
          return Occurrence.none if DatesCalculator.new(template.rule).call(date_key..date_key).exclude?(date_key)

          relation([{ template_id: template.id, date_key: }])
        end

        def relation(pairs)
          return Occurrence.none if pairs.empty?

          Occurrence.from(Arel.sql("(#{derived_sql(pairs)}) AS #{Occurrence.table_name}"))
        end

        private

        def derived_sql(pairs)
          MERGE_SQL % {
            pairs: ApplicationRecord.connection.quote(pairs.to_json),
            tz: ApplicationRecord.connection.quote(Time.zone.tzinfo.name)
          }
        end
      end

      def initialize(templates, period)
        @templates = templates
        @period = period
      end

      def call
        self.class.relation(pairs).where(scheduled_at: @period)
      end

      private

      def pairs
        @pairs ||= (rule_pairs + moved_pairs).uniq
      end

      def rule_pairs
        @templates.select { |template| template.rule && active_in_span?(template.rule) }.flat_map do |template|
          DatesCalculator.new(template.rule).call(date_span).map { |date_key| { template_id: template.id, date_key: } }
        end
      end

      def active_in_span?(rule)
        rule.starts_on <= date_span.end && (rule.ends_on.nil? || rule.ends_on >= date_span.begin)
      end

      def moved_pairs
        Override.where(template_id: @templates.map(&:id), deleted_at: nil)
          .where(scheduled_at: @period)
          .pluck(:template_id, :date_key)
          .map { |template_id, date_key| { template_id:, date_key: } }
      end

      def date_span
        @period.begin.to_date..@period.end.to_date
      end
    end
  end
end

# frozen_string_literal: true

module Tasks
  class ListService
    def initialize(period, search_params = {})
      @period = period
      @search_params = search_params
    end

    def call
      (one_offs + occurrences).sort_by { |task| task[:scheduled_at] }
    end

    private

    def one_offs
      OneOffsListService.new(@period, @search_params).call.map do |task|
        unify(task, kind: 'one_off', id: task.id)
      end
    end

    def occurrences
      Recurring::OverridesListService.new(templates, @period, @search_params).call.map do |occurrence|
        unify(occurrence, kind: 'occurrence', template_id: occurrence.template_id, date_key: occurrence.date_key)
      end
    end

    def unify(task, identity)
      task.slice(*ATTRIBUTES).symbolize_keys.merge(identity)
    end

    def templates
      scope = Recurring::Template.includes(:rule)
      template_id = @search_params[:template_id]
      template_id.present? ? scope.where(id: template_id) : scope
    end
  end
end

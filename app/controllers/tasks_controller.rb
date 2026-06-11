# frozen_string_literal: true

class TasksController < ApplicationController
  MAX_PERIOD = 366.days

  def index
    render json: Tasks::ListService.new(period, search_params).call
  rescue ArgumentError, ActionController::ParameterMissing
    head :bad_request
  end

  private

  def period
    from = parse(params.require(:from))
    to = parse(params.require(:to))
    raise ArgumentError if to - from > MAX_PERIOD

    from..to
  end

  def parse(value)
    raise ArgumentError unless value.is_a?(String)

    Time.zone.parse(value) || raise(ArgumentError)
  end

  def search_params
    query = params.fetch(:q, ActionController::Parameters.new)
    raise ArgumentError unless query.is_a?(ActionController::Parameters)

    validate_statuses(query)
    query.permit(:status, :assignee_id, :template_id, :query, :tag, statuses: [])
  end

  def validate_statuses(query)
    statuses = [query[:status], *query[:statuses]].compact_blank
    raise ArgumentError unless statuses.all? { |status| Tasks::STATUSES.include?(status) }
  end
end

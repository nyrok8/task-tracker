# frozen_string_literal: true

module TaskParams
  TASK_ATTRIBUTES = [*(Tasks::ATTRIBUTES - [:tags]), { tags: [] }].freeze

  private

  def task_params(wrapper)
    params.expect(wrapper => TASK_ATTRIBUTES)
  end
end

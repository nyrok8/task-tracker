# frozen_string_literal: true

module Tasks
  class OneOffsController < ApplicationController
    include TaskParams

    before_action :find_one_off, only: %i[show update destroy]

    def show
      render json: @one_off
    end

    def create
      one_off = OneOff.new(task_params(:one_off))
      validation = TaskContract.new(record: one_off).call(one_off.attributes)
      if validation.success?
        one_off.save!
        render json: one_off, status: :created
      else
        render json: { errors: validation.errors.to_h }, status: :unprocessable_content
      end
    end

    def update
      @one_off.assign_attributes(task_params(:one_off))
      validation = TaskContract.new(record: @one_off).call(@one_off.attributes)
      if validation.success?
        @one_off.save!
        render json: @one_off
      else
        render json: { errors: validation.errors.to_h }, status: :unprocessable_content
      end
    end

    def destroy
      @one_off.destroy!
      head :no_content
    end

    private

    def find_one_off
      @one_off = OneOff.find(params.expect(:id))
    end
  end
end

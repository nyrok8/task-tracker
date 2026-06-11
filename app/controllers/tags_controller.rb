# frozen_string_literal: true

class TagsController < ApplicationController
  before_action :find_tag, only: %i[show update destroy]

  def index
    render json: Tag.all
  end

  def show
    render json: @tag
  end

  def create
    tag = Tag.new(tag_params)
    validation = TagContract.new(tag:).call(tag.attributes)
    if validation.success?
      tag.save!
      Tag.reset_names
      render json: tag, status: :created
    else
      render json: { errors: validation.errors.to_h }, status: :unprocessable_content
    end
  end

  def update
    @tag.assign_attributes(tag_params)
    validation = TagContract.new(tag: @tag).call(@tag.attributes)
    if validation.success?
      @tag.save!
      Tag.reset_names
      render json: @tag
    else
      render json: { errors: validation.errors.to_h }, status: :unprocessable_content
    end
  end

  def destroy
    return render json: { errors: ['system tag cant be deleted'] }, status: :unprocessable_content if @tag.system?

    @tag.destroy!
    Tag.reset_names
    head :no_content
  end

  private

  def find_tag
    @tag = Tag.find(params.expect(:id))
  end

  def tag_params
    params.expect(tag: [:name])
  end
end

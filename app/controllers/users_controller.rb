# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :find_user, only: %i[show update destroy]

  def index
    render json: User.all
  end

  def show
    render json: @user
  end

  def create
    user = User.new(user_params)
    validation = UserContract.new.call(user.attributes)
    if validation.success?
      user.save!
      render json: user, status: :created
    else
      render json: { errors: validation.errors.to_h }, status: :unprocessable_content
    end
  end

  def update
    @user.assign_attributes(user_params)
    validation = UserContract.new.call(@user.attributes)
    if validation.success?
      @user.save!
      render json: @user
    else
      render json: { errors: validation.errors.to_h }, status: :unprocessable_content
    end
  end

  def destroy
    @user.destroy!
    head :no_content
  end

  private

  def find_user
    @user = User.find(params.expect(:id))
  end

  def user_params
    params.expect(user: [:name])
  end
end

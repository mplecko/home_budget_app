module Users
  class MaximumBudgetsController < ApplicationController
    def show
      render json: { maximum_budget: current_user.maximum_budget }, status: :ok
    end

    def update
      if params[:maximum_budget].blank? || params[:maximum_budget].to_f <= 0
        current_user.errors.add(:maximum_budget, 'must be present and greater than 0')
        raise ActiveRecord::RecordInvalid, current_user
      end

      new_maximum_budget = params[:maximum_budget].to_f
      current_user.update_maximum_budget(new_maximum_budget)

      render json: { message: 'Maximum budget updated successfully', maximum_budget: current_user.maximum_budget }, status: :ok
    end
  end
end

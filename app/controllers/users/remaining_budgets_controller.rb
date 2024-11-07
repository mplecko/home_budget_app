module Users
  class RemainingBudgetsController < ApplicationController
    def show
      render json: { remaining_budget: current_user.remaining_budget }, status: :ok
    end
  end
end

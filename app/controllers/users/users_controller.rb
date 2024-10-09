module Users
  class UsersController < ApplicationController
    def show_budget
      render json: { budget: current_user.budget }, status: :ok
    end
  end
end

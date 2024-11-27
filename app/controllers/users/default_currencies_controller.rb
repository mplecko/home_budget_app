module Users
  class DefaultCurrenciesController < ApplicationController
    def show
      render json: { default_currency: current_user.default_currency }, status: :ok
    end

    def update
      if params[:default_currency].blank? || params[:default_currency].length != 3
        current_user.errors.add(:default_currency, 'must be present and have a length of 3')
        raise ActiveRecord::RecordInvalid, current_user
      end

      new_default_currency = params[:default_currency]
      current_user.update_default_currency(new_default_currency)

      render json: { message: 'Default currency updated successfully', default_currency: current_user.default_currency }, status: :ok
    end
  end
end

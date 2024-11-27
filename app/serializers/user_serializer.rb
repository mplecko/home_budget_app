class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :first_name, :last_name, :email, :remaining_budget, :maximum_budget, :default_currency
end

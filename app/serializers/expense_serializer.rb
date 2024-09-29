class ExpenseSerializer < ActiveModel::Serializer
  attributes :id, :description, :date, :amount

  belongs_to :category, serializer: CategorySerializer
end

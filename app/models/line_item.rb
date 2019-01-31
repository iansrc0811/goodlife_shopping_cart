class LineItem < ApplicationRecord
  belongs_to :product
  belongs_to :order
  delegate :user, to: :order
  delegate :uid, to: :product
end

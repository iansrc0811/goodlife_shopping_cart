class LineItem < ApplicationRecord
  belongs_to :product
  belongs_to :order
  delegate :user, to: :order
  delegate :uid, to: :product

  def set_total_price(set_pcs=nil)
    set_pcs ||= self.pcs
    update!(total_price: set_pcs * product.price, pcs: set_pcs)
  end
end

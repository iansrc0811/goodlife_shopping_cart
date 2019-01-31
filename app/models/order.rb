class Order < ApplicationRecord
  belongs_to :user
  has_many :line_items
  has_many :products, through: :line_items

  after_create do
    default_name
  end

  enum status: {
    cart:     1,  # 購物車
    ready:    2,  # 新成立訂單
    shipped:  3,  # 已出貨
    returned: 4,  # 已退貨
  }
  enum financial_status: {
    not_paid:        1,
    paid:            2,
    pending_refund:  3,
    refunded:        4,
  }

  def default_name
    name = '#' + sprintf("%05d", id)
    save!
  end

end

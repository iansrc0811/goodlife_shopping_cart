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

  def add_to_cart(product, pcs)
    raise "數量需大於 1 !" if pcs <= 0
    with_lock do
      Order.transaction do
        byebug
        item = line_items.where(product_id: product.id).last.presence
        if item.nil?
          line_items.create!(product_id: product.id, pcs: pcs, total_price: product.price * pcs)
        else
          item.pcs += pcs
          item.total_price = product.price * item.pcs
          item.save!
        end
        set_total_price
      end
    end
  end

  def set_total_price
    if line_items.exists?
      update!(price: line_items.sum(&:total_price))
    end
  end

end

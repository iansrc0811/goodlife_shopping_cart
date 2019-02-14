class AddConfirmAtToOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :confirm_at, :datetime
  end
end

class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.references :user, foreign_key: true
      t.string :name
      t.integer :status, default: 1, null: false
      t.integer :financial_status, default: 1, null: false
      t.integer :price
      t.timestamps
    end
  end
end

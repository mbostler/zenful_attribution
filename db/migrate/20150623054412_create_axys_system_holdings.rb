class CreateAxysSystemHoldings < ActiveRecord::Migration
  def change
    create_table :axys_system_holdings do |t|
      t.integer :portfolio_id
      t.integer :company_id
      t.integer :bmv_holding_id
      t.integer :emv_holding_id
      t.date :date
      t.float :quantity
      t.float :unit_cost
      t.float :total_cost
      t.float :price
      t.float :market_value
      t.float :pct_assets
      t.float :yield

      t.timestamps null: false
    end
  end
end

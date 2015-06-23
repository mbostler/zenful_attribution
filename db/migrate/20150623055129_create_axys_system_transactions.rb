class CreateAxysSystemTransactions < ActiveRecord::Migration
  def change
    create_table :axys_system_transactions do |t|
      t.integer :portfolio_id
      t.integer :company_id
      t.integer :holding_id
      t.date :date
      t.string :code
      t.string :security
      t.string :close_method
      t.string :lot
      t.date :trade_date
      t.date :settle_date
      t.string :sd_type
      t.string :sd_symbol
      t.float :quantity
      t.float :trade_amount
      t.string :cusip
      t.string :symbol

      t.timestamps null: false
    end
  end
end

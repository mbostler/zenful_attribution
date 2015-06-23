class CreateAttributionHoldings < ActiveRecord::Migration
  def change
    create_table :attribution_holdings do |t|
      t.integer :company_id
      t.integer :day_id
      t.float :performance
      t.float :contribution

      t.timestamps null: false
    end
  end
end

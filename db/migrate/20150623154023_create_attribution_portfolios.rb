class CreateAttributionPortfolios < ActiveRecord::Migration[5.1]
  def change
    create_table :attribution_portfolios do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end

class CreateAttributionPortfolios < ActiveRecord::Migration
  def change
    create_table :attribution_portfolios do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end

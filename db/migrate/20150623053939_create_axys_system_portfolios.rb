class CreateAxysSystemPortfolios < ActiveRecord::Migration
  def change
    create_table :axys_system_portfolios do |t|
      t.string :name

      t.timestamps null: false
    end
  end
end

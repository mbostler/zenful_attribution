class CreateAxysSystemHoldingsReports < ActiveRecord::Migration
  def change
    create_table :axys_system_holdings_reports do |t|
      t.integer :portfolio_id
      t.date :date

      t.timestamps null: false
    end
  end
end

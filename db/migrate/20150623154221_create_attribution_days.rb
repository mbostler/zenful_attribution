class CreateAttributionDays < ActiveRecord::Migration
  def change
    create_table :attribution_days do |t|
      t.integer :portfolio_id
      t.date :date
      t.float :performance

      t.timestamps null: false
    end
  end
end

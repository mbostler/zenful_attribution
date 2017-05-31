class CreateHolidays < ActiveRecord::Migration[5.1]
  def change
    create_table :holidays do |t|
      t.integer :year
      t.integer :month
      t.integer :day

      t.timestamps null: false
    end
  end
end

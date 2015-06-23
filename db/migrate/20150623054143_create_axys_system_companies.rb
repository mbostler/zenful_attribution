class CreateAxysSystemCompanies < ActiveRecord::Migration
  def change
    create_table :axys_system_companies do |t|
      t.string :cusip
      t.string :ticker
      t.string :code
      t.string :name
      t.string :security

      t.timestamps null: false
    end
  end
end

class AddSymbolToAxysSystemCompanies < ActiveRecord::Migration
  def change
    add_column :axys_system_companies, :symbol, :string
  end
end

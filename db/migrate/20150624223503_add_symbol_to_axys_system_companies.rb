class AddSymbolToAxysSystemCompanies < ActiveRecord::Migration[5.1]
  def change
    add_column :axys_system_companies, :symbol, :string
  end
end

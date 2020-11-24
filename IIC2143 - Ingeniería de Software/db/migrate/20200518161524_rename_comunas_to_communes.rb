class RenameComunasToCommunes < ActiveRecord::Migration[5.2]
  def change
    rename_table :comunas, :communes
  end
end

class RenameGustosToInterests < ActiveRecord::Migration[5.2]
  def change
    rename_table :gustos, :interests
  end
end

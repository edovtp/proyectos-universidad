class CreateMenus < ActiveRecord::Migration[5.2]
  def change
    create_table :menus do |t|
      t.string :nombre
      t.integer :idlocal
      t.string :descripcion
      t.integer :precio

      t.timestamps
    end
  end
end

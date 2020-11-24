class AddAttributesToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :admin, :boolean, default: false
    add_column :users, :nombre, :string
    add_column :users, :descripcion, :text
    add_column :users, :edad, :integer
    add_column :users, :telefono, :string
    add_column :users, :commune_id, :integer
  end
end

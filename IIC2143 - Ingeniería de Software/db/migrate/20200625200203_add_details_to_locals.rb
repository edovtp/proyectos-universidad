class AddDetailsToLocals < ActiveRecord::Migration[5.2]
  def change
    add_column :locals, :telefono, :string
    add_column :locals, :direccion, :string
  end
end

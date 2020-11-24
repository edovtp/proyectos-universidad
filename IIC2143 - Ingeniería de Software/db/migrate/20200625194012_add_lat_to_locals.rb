class AddLatToLocals < ActiveRecord::Migration[5.2]
  def change
    add_column :locals, :lat, :decimal
    add_column :locals, :long, :decimal
  end
end

class AddNombreAndFechaToValuation < ActiveRecord::Migration[5.2]
  def change
    add_column :valuations, :nombre, :string
    add_column :valuations, :fecha, :date
  end
end

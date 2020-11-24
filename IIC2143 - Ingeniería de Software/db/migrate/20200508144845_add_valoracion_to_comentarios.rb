class AddValoracionToComentarios < ActiveRecord::Migration[5.2]
  def change
    add_column :comentarios, :valoracion, :integer
  end
end

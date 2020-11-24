class DeleteValoracionesFromComments < ActiveRecord::Migration[5.2]
  def change
    remove_column :comments, :valoracion
  end
end

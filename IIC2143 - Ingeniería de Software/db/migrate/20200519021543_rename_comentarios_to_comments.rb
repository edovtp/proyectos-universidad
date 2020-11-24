class RenameComentariosToComments < ActiveRecord::Migration[5.2]
  def change
    rename_table :comentarios, :comments
  end
end

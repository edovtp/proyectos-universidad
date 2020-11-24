class CreateComentarios < ActiveRecord::Migration[5.2]
  def change
    create_table :comentarios do |t|
      t.text :contenido
      t.integer :idusuario
      t.integer :idlocal

      t.timestamps
    end
  end
end
